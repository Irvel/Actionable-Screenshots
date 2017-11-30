import keras
import argparse
# from keras.utils.generic_utils import CustomObjectScope
import coremltools


def gen_argparser():
    parser = argparse.ArgumentParser(description="Convert a Keras Model to a CoreML model")
    parser.add_argument("path", type=str)
    parser.add_argument("out", type=str)
    return parser


def main():
    parser = gen_argparser()
    args = parser.parse_args()

    converted_model = coremltools.converters.keras.convert(args.path,
                                                           input_names="image",
                                                           image_input_names="image",
                                                           class_labels=["facebook", "notes", "other", "whatsapp", "tinder", "reddit", "youtube", "siri", "twitter", "settings"],
                                                           output_names="classLabelProbs",
                                                           image_scale=1/255.0)

    converted_model.save(args.out)


if __name__ == "__main__":
    main()
