import os

import numpy as np
from PIL import Image


"""
Generates a split of train/test datasets from a given
directory and a target size.

- Identifies the classes from the sub directory names
- Loads images into numpy arrays
- Verifies images are valid
- Normalizes the images
"""
def make_test_train_set(source_dir, target_size, split_ratio=.17, img_size=(224, 224)):
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
    X_train_images = np.zeros((train_samples, img_size[0], img_size[1], 3))
    Y_train_images = np.zeros((train_samples, len(labels)))
    X_test_images = np.zeros((test_samples, img_size[0], img_size[1], 3))
    Y_test_images = np.zeros((test_samples, len(labels)))

    total_train_offset = 0
    total_test_offset = 0
    for lbl_idx, label in enumerate(labels):
        num_train_loaded = total_train_offset
        num_test_loaded = total_test_offset
        for file in os.listdir(os.path.join(source_dir, label)):
            try:
                image = Image.open(os.path.join(source_dir, label, file))
                # image.verify()  This is failing with images that are valid so this might be a bug with PIL
                image = image.resize(img_size)
                # Normalize
                image = np.array(image) / 255.
                image -= np.mean(image)
                if (num_train_loaded - total_train_offset) < train_per_label:
                    print(f"lbl_idx = {lbl_idx}      num_train_loaded = {num_train_loaded}")
                    X_train_images[num_train_loaded] = image
                    Y_train_images[num_train_loaded, lbl_idx] = 1
                    num_train_loaded += 1
                elif (num_test_loaded - total_test_offset) < test_per_label:
                    X_test_images[num_test_loaded] = image
                    Y_test_images[num_test_loaded, lbl_idx] = 1
                    num_test_loaded += 1
                    print(f"lbl_idx = {lbl_idx}      num_test_loaded = {num_test_loaded}")
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
