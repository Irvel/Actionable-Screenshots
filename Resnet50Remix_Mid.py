import keras.backend as K
import numpy as np
import scipy.misc
from IPython.display import SVG
from keras import layers
from keras.applications.imagenet_utils import preprocess_input
from keras.callbacks import (LearningRateScheduler, ModelCheckpoint,
                             ReduceLROnPlateau)
from keras.initializers import glorot_uniform
from keras.layers import (Activation, Add, AveragePooling2D,
                          BatchNormalization, Conv2D, Dense, Flatten,
                          GlobalMaxPooling2D, Input, MaxPooling2D,
                          ZeroPadding2D)
from keras.preprocessing.image import ImageDataGenerator
from keras.models import Model, load_model
from keras.optimizers import Adam
from keras.preprocessing import image
from keras.utils import layer_utils, plot_model
from keras.utils.data_utils import get_file
from keras.utils.vis_utils import model_to_dot
from matplotlib.pyplot import imshow

from PIL import Image
import random


import os


K.set_image_data_format('channels_last')
K.set_learning_phase(1)


"""
Generates a split of train/test datasets from a given
directory and a target size.

- Identifies the classes from the sub directory names
- Loads images into numpy arrays
- Verifies images are valid
- Normalizes the images
"""


def load_single_image(source_image, img_size=(224, 224)):
    assert os.path.exists(source_image)

    single_image = np.zeros((1, img_size[0], img_size[1], 3))

    image = Image.open(source_image)
    image = image.resize(img_size)
    image.load()
    image_background = Image.new("RGB", image.size, (255, 255, 255))
    image_background.paste(image, mask=image.split()[3])  # Remove any alpha channel
    image = np.array(image_background) / 255.
    single_image[0] = image
    return single_image


def make_test_train_set(source_dir, target_size, split_ratio=.2, img_size=(224, 224)):
    assert isinstance(target_size, int)
    assert target_size > 1
    assert os.path.isdir(source_dir)

    labels = []
    for subdir in os.listdir(source_dir):
        if os.path.isdir(os.path.join(source_dir, subdir)):
            labels.append(subdir)

    if not labels:
        raise Exception(f"Not class subdirectories were found in {source_dir}")

    # Calculate split sample sizes
    train_samples = int(target_size * (1 - split_ratio))
    test_samples = int(target_size * split_ratio)

    train_per_label = train_samples // len(labels)
    test_per_label = test_samples // len(labels)

    # HACK
    train_samples = train_per_label * len(labels)
    test_samples = test_per_label * len(labels)

    print(f"Found {len(labels)} classes: {labels}")
    print(f"Generating {train_per_label} training examples for each class (total of {train_samples})")
    print(f"Generating {test_per_label} test examples for each class (total of {test_samples})")

    # Load the images
    X_train_images = np.zeros((train_samples, img_size[1], img_size[0], 3), dtype=np.float64)
    Y_train_images = np.zeros((train_samples, len(labels)), dtype=np.float64)
    X_test_images = np.zeros((test_samples, img_size[1], img_size[0], 3), dtype=np.float64)
    Y_test_images = np.zeros((test_samples, len(labels)), dtype=np.float64)

    total_train_offset = 0
    total_test_offset = 0
    for lbl_idx, label in enumerate(labels):
        num_train_loaded = total_train_offset
        num_test_loaded = total_test_offset
        class_files = os.listdir(os.path.join(source_dir, label))
        for file in random.sample(class_files, len(class_files)):
            try:
                image = Image.open(os.path.join(source_dir, label, file))
                # image.verify()  This is failing with images that are valid so this might be a bug with PIL
                image = image.resize(img_size)
                #image.save("/output/dimensioncheck.jpg")
                # Normalize
                image = np.array(image, dtype=np.float64) / 255.
                #image -= np.mean(image)
                if (num_train_loaded - total_train_offset) < train_per_label:
                    #print(f"lbl_idx = {lbl_idx}      num_train_loaded = {num_train_loaded}")
                    X_train_images[num_train_loaded] = image
                    Y_train_images[num_train_loaded, lbl_idx] = 1
                    num_train_loaded += 1
                elif (num_test_loaded - total_test_offset) < test_per_label:
                    X_test_images[num_test_loaded] = image
                    Y_test_images[num_test_loaded, lbl_idx] = 1
                    num_test_loaded += 1
                    #print(f"lbl_idx = {lbl_idx}      num_test_loaded = {num_test_loaded}")
                else:
                    break
            except IOError as e:
                print(e)
                print(f"Error. Couldn't read image from file \"{os.path.join(source_dir, label, file)}\", skipping...")

        if (num_train_loaded - total_train_offset) < train_per_label or (num_test_loaded - total_test_offset) < test_per_label:
            raise Exception(f"Not enough files were found in directory \"{label}\" "
                            f"to satisfy the target sample size. ({train_per_label + test_per_label})")

        total_train_offset += (num_train_loaded - total_train_offset)
        total_test_offset += (num_test_loaded - total_test_offset)

    x_train_mean = np.mean(X_train_images, axis=0)
    X_train_images -= x_train_mean
    X_test_images -= x_train_mean

    print()
    print(f"Loaded X training set with shape {X_train_images.shape}")
    print(f"Loaded Y training set with shape {Y_train_images.shape}")
    print(f"Loaded X test set with shape {X_test_images.shape}")
    print(f"Loaded Y test set with shape {Y_test_images.shape}")

    return X_train_images, Y_train_images, X_test_images, Y_test_images, labels



def identity_block(X, f, filters, stage, block):
    """
    Implementation of the identity block as defined in Figure 3

    Arguments:
    X -- input tensor of shape (m, n_H_prev, n_W_prev, n_C_prev)
    f -- integer, specifying the shape of the middle CONV's window for the main path
    filters -- python list of integers, defining the number of filters in the CONV layers of the main path
    stage -- integer, used to name the layers, depending on their position in the network
    block -- string/character, used to name the layers, depending on their position in the network

    Returns:
    X -- output of the identity block, tensor of shape (n_H, n_W, n_C)
    """

    # defining name basis
    conv_name_base = 'res' + str(stage) + block + '_branch'
    bn_name_base = 'bn' + str(stage) + block + '_branch'

    # Retrieve Filters
    F1, F2, F3 = filters

    # Save the input value. You'll need this later to add back to the main path.
    X_shortcut = X

    # First component of main path
    X = Conv2D(filters=F1, kernel_size=(1, 1), strides=(1, 1), padding='valid',
               name=conv_name_base + '2a', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2a')(X)
    X = Activation('relu')(X)


    # Second component of main path
    X = Conv2D(filters=F2, kernel_size=(f, f), strides=(1, 1), padding='same',
               name=conv_name_base + '2b', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2b')(X)
    X = Activation('relu')(X)

    # Third component of main path
    X = Conv2D(filters=F3, kernel_size=(1, 1), strides=(1, 1), padding='valid',
               name=conv_name_base + '2c', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2c')(X)

    X = Add()([X, X_shortcut])
    X = Activation('relu')(X)

    return X


def convolutional_block(X, f, filters, stage, block, s=2):
    """
    Implementation of the convolutional block as defined in Figure 4

    Arguments:
    X -- input tensor of shape (m, n_H_prev, n_W_prev, n_C_prev)
    f -- integer, specifying the shape of the middle CONV's window for the main path
    filters -- python list of integers, defining the number of filters in the CONV layers of the main path
    stage -- integer, used to name the layers, depending on their position in the network
    block -- string/character, used to name the layers, depending on their position in the network
    s -- Integer, specifying the stride to be used

    Returns:
    X -- output of the convolutional block, tensor of shape (n_H, n_W, n_C)
    """

    # defining name basis
    conv_name_base = 'res' + str(stage) + block + '_branch'
    bn_name_base = 'bn' + str(stage) + block + '_branch'

    # Retrieve Filters
    F1, F2, F3 = filters

    # Save the input value
    X_shortcut = X

    ##### MAIN PATH #####
    # First component of main path
    X = Conv2D(F1, (1, 1), strides=(s, s), name=conv_name_base +
               '2a', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2a')(X)
    X = Activation('relu')(X)

    # Second component of main path
    X = Conv2D(F2, (f, f), strides=(1, 1), padding='same',
               name=conv_name_base + '2b', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2b')(X)
    X = Activation('relu')(X)

    # Third component of main path
    X = Conv2D(F3, (1, 1), strides=(1, 1), padding='valid',
               name=conv_name_base + '2c', kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name=bn_name_base + '2c')(X)

    X_shortcut = Conv2D(F3, (1, 1), strides=(s, s), padding='valid',
                        name=conv_name_base + '1', kernel_initializer=glorot_uniform(seed=0))(X)
    X_shortcut = BatchNormalization(axis=3, name=bn_name_base + '1')(X)

    X = Add()([X, X_shortcut])
    X = Activation('relu')(X)

    return X


def ResNet50(input_shape=(64, 64, 3), classes=6):
    """
    Implementation of the popular ResNet50 the following architecture:
    CONV2D -> BATCHNORM -> RELU -> MAXPOOL -> CONVBLOCK -> IDBLOCK*2 -> CONVBLOCK -> IDBLOCK*3
    -> CONVBLOCK -> IDBLOCK*5 -> CONVBLOCK -> IDBLOCK*2 -> AVGPOOL -> TOPLAYER

    Arguments:
    input_shape -- shape of the images of the dataset
    classes -- integer, number of classes

    Returns:
    model -- a Model() instance in Keras
    """

    # Define the input as a tensor with shape input_shape
    X_input = Input(input_shape)

    # Zero-Padding
    X = ZeroPadding2D((3, 3))(X_input)

    # Stage 1
    X = Conv2D(64, (7, 7), strides=(2, 2), name='conv1',
               kernel_initializer=glorot_uniform(seed=0))(X)
    X = BatchNormalization(axis=3, name='bn_conv1')(X)
    X = Activation('relu')(X)
    X = MaxPooling2D((3, 3), strides=(2, 2))(X)

    # Stage 2
    X = convolutional_block(
        X, f=3, filters=[64, 64, 256], stage=2, block='a', s=1)
    X = identity_block(X, 3, [64, 64, 256], stage=2, block='b')
    X = identity_block(X, 3, [64, 64, 256], stage=2, block='c')

    # Stage 3
    X = convolutional_block(
        X, f=3, filters=[64, 64, 256], stage=3, block='a', s=2)
    X = identity_block(X, 3, [64, 64, 256], stage=3, block='b')
    X = identity_block(X, 3, [64, 64, 256], stage=3, block='c')
    X = identity_block(X, 3, [64, 64, 256], stage=3, block='d')
    X = identity_block(X, 3, [64, 64, 256], stage=3, block='e')

    # Stage 4
    X = convolutional_block(
        X, f=3, filters=[128, 128, 512], stage=4, block='a', s=2)
    X = identity_block(X, 3, [128, 128, 512], stage=4, block='b')
    X = identity_block(X, 3, [128, 128, 512], stage=4, block='c')
    X = identity_block(X, 3, [128, 128, 512], stage=4, block='d')
    X = identity_block(X, 3, [128, 128, 512], stage=4, block='e')
    X = identity_block(X, 3, [128, 128, 512], stage=4, block='f')

    # Stage 5
    X = convolutional_block(
        X, f=3, filters=[256, 256, 1024], stage=5, block='a', s=2)
    X = identity_block(X, 3, [256, 256, 1024], stage=5, block='b')
    X = identity_block(X, 3, [256, 256, 1024], stage=5, block='c')

    # AVGPOOL
    X = AveragePooling2D(pool_size=(2, 2), name="avg_pool")(X)


    # output layer
    X = Flatten()(X)
    X = Dense(classes, activation='softmax', name='fc' + str(classes),
              kernel_initializer=glorot_uniform(seed=0))(X)

    # Create model
    model = Model(inputs=X_input, outputs=X, name='ResNet50')

    return model


def lr_schedule(epoch):
    """Learning Rate Schedule
    Learning rate is scheduled to be reduced after 80, 120, 160, 180 epochs.
    Called automatically every epoch as part of callbacks during training.
    # Arguments
        epoch (int): The number of epochs
    # Returns
        lr (float32): learning rate
    """
    lr = 1e-3
    if epoch > 180:
        lr *= 0.5e-3
    elif epoch > 160:
        lr *= 1e-3
    elif epoch > 120:
        lr *= 1e-2
    elif epoch > 80:
        lr *= 1e-1
    print('Learning rate: ', lr)
    return lr


def main():
    out_model_dir = "/output/"
    data_dir = "/screenshots_train"
    num_examples = 13005
    num_epochs = 12
    batch_size = 32
    image_size = (260, 424)
    data_augmentation = False
    X_train, Y_train, X_test, Y_test, labels = make_test_train_set(data_dir,
                                                                   num_examples,
                                                                   0.17,
                                                                   image_size)

    with open(os.path.join(out_model_dir, "class_labels"), "w") as file:
        file.write(str(labels))


    model = ResNet50(input_shape=X_train[0].shape, classes=len(labels))
    model.compile(optimizer=Adam(lr=lr_schedule(0)),
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])

    model.summary()

    print ("number of training examples = " + str(X_train.shape[0]))
    print ("number of test examples = " + str(X_test.shape[0]))
    print ("X_train shape: " + str(X_train.shape))
    print ("Y_train shape: " + str(Y_train.shape))
    print ("X_test shape: " + str(X_test.shape))
    print ("Y_test shape: " + str(Y_test.shape))

    # Prepare model saving directory.
    model_name = "resnet_remix_screenshots.{epoch:02d}.h5"
    if not os.path.isdir(out_model_dir):
        os.makedirs(out_model_dir)
    filepath = os.path.join(out_model_dir, model_name)

    # Prepare callbacks for model saving and for learning rate adjustment.
    checkpoint = ModelCheckpoint(filepath=filepath,
                                 monitor='val_acc',
                                 verbose=1,
                                 save_best_only=True)

    lr_scheduler = LearningRateScheduler(lr_schedule)

    lr_reducer = ReduceLROnPlateau(factor=np.sqrt(0.1),
                                   cooldown=0,
                                   patience=5,
                                   min_lr=0.5e-6)

    callbacks = [checkpoint, lr_reducer, lr_scheduler]


    # Run training, with or without data augmentation.
    if not data_augmentation:
        print("Training model without augmentation...")
        model.fit(X_train, Y_train,
                  batch_size=batch_size,
                  epochs=num_epochs,
                  validation_data=(X_test, Y_test),
                  shuffle=True,
                  callbacks=callbacks)

    else:
        print("Using real-time data augmentation.")
        # This will do preprocessing and realtime data augmentation:
        datagen = ImageDataGenerator(
            # set input mean to 0 over the dataset
            featurewise_center=False,
            # set each sample mean to 0
            samplewise_center=False,
            # divide inputs by std of dataset
            featurewise_std_normalization=False,
            # divide each input by its std
            samplewise_std_normalization=False,
            # apply ZCA whitening
            zca_whitening=False,
            # randomly rotate images in the range (deg 0 to 180)
            rotation_range=0,
            # randomly shift images horizontally
            width_shift_range=0.5,
            # randomly shift images vertically
            height_shift_range=0.5,
            # randomly flip images
            horizontal_flip=False,
            # randomly flip images
            vertical_flip=False)

        # Compute quantities required for featurewise normalization
        # (std, mean, and principal components if ZCA whitening is applied)
        datagen.fit(X_train)

        # Fit the model on the batches generated by datagen.flow()
        steps_per_epoch = int(np.ceil(X_train.shape[0] / float(batch_size)))
        model.fit_generator(datagen.flow(X_train, Y_train, batch_size=batch_size),
                            steps_per_epoch=steps_per_epoch,
                            validation_data=(X_test, Y_test),
                            epochs=num_epochs, verbose=1, workers=4,
                            callbacks=callbacks)


    # Score trained model
    scores = model.evaluate(X_test, Y_test, verbose=1)
    print("Test loss:", scores[0])
    print("Test accuracy:", scores[1])



if __name__ == '__main__':
    main()
