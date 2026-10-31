
import pytest

from src.ml.predict_crop import predict_crop, FEATURES, FEATURE_RANGES


@pytest.fixture
def valid_input():
    return {
        "N": 90,
        "P": 42,
        "K": 43,
        "temperature": 20.9,
        "humidity": 82.0,
        "ph": 6.5
    }


def test_valid_prediction(valid_input):
    results = predict_crop(valid_input)

    assert len(results) == 3
    assert all("crop" in item for item in results)
    assert all("confidence" in item for item in results)


def test_missing_feature_rejected(valid_input):
    valid_input.pop("ph")

    with pytest.raises(ValueError, match="Required inputs"):
        predict_crop(valid_input)


def test_extra_feature_rejected(valid_input):
    valid_input["rainfall"] = 200

    with pytest.raises(ValueError, match="Required inputs"):
        predict_crop(valid_input)


def test_non_numeric_input_rejected(valid_input):
    valid_input["N"] = "abc"

    with pytest.raises(ValueError, match="N must be a valid number"):
        predict_crop(valid_input)


def test_infinite_input_rejected(valid_input):
    valid_input["N"] = float("inf")

    with pytest.raises(ValueError, match="finite numbers"):
        predict_crop(valid_input)


def test_missing_value_rejected(valid_input):
    valid_input["N"] = None

    with pytest.raises(ValueError, match="cannot be missing"):
        predict_crop(valid_input)


@pytest.mark.parametrize("feature", FEATURES)
def test_out_of_range_input_rejected(valid_input, feature):
    minimum, maximum = FEATURE_RANGES[feature]
    valid_input[feature] = maximum + 1

    with pytest.raises(ValueError):
        predict_crop(valid_input)


def test_string_number_is_accepted(valid_input):
    valid_input["N"] = "90"

    results = predict_crop(valid_input)

    assert len(results) == 3
