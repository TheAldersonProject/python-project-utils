"""Tests for the BasicLogger class."""

import uuid
from unittest.mock import MagicMock, patch

import pytest

from commons.core.basic_logger import BasicLogger, LogLevel


@pytest.fixture
def mock_structlog_configure():
    """Fixture to mock structlog.configure."""
    with patch("structlog.configure") as mock_configure:
        yield mock_configure


@pytest.fixture
def mock_structlog_logger():
    """Fixture to mock structlog.get_logger."""
    with patch("structlog.get_logger") as mock_get_logger:
        mock_logger = MagicMock()
        mock_get_logger.return_value = mock_logger
        yield mock_logger


@pytest.fixture
def mock_structlog(mock_structlog_configure, mock_structlog_logger):
    """Fixture to mock structlog.configure and structlog.get_logger."""
    yield mock_structlog_configure, mock_structlog_logger


class TestBasicLogger:
    """Test suite for BasicLogger class."""

    def test_init_with_default_parameters(self, mock_structlog_configure):
        """Test initialization with default parameters."""
        logger = BasicLogger()

        # Verify basicConfig was called with correct parameters
        assert logger._uuid is not None
        assert len(logger._uuid) > 0

        # Verify structlog.configure was called with correct parameters
        mock_structlog_configure.assert_called_once()
        call_args = mock_structlog_configure.call_args[1]
        assert call_args["cache_logger_on_first_use"] is False
        assert len(call_args["processors"]) == 6

        # Verify log level is set to DEBUG by default
        # Check that wrapper_class is the result of make_filtering_bound_logger
        assert "wrapper_class" in call_args
        assert callable(call_args["wrapper_class"])

    def test_init_with_custom_log_level(self, mock_structlog_configure):
        """Test initialization with custom log level."""
        logger = BasicLogger(log_level=LogLevel.ERROR)  # noqa: F841

        # Verify log level is set to ERROR
        call_args = mock_structlog_configure.call_args[1]
        # Check that wrapper_class is the result of make_filtering_bound_logger
        assert "wrapper_class" in call_args
        assert callable(call_args["wrapper_class"])

    def test_init_with_custom_uuid(self):
        """Test initialization with custom UUID."""
        custom_uuid = "test-uuid-123"
        logger = BasicLogger(logger_uuid=custom_uuid)

        assert logger._uuid == custom_uuid

    @patch("uuid.uuid4")
    def test_init_generates_uuid_when_not_provided(self, mock_uuid4):
        """Test that UUID is generated when not provided."""
        test_uuid = uuid.UUID("12345678-1234-5678-1234-567812345678")
        mock_uuid4.return_value = test_uuid

        logger = BasicLogger()

        assert logger._uuid == str(test_uuid)
        mock_uuid4.assert_called_once()

    def test_info_method(self, mock_structlog_logger):
        """Test info method."""
        logger = BasicLogger(logger_uuid="test-uuid")
        logger.info("Test info message", extra_field="value")

        mock_structlog_logger.info.assert_called_once_with("Test info message", extra_field="value", uuid="test-uuid")

    def test_debug_method(self, mock_structlog_logger):
        """Test debug method."""
        logger = BasicLogger(logger_uuid="test-uuid")
        logger.debug("Test debug message", extra_field="value")

        mock_structlog_logger.debug.assert_called_once_with("Test debug message", extra_field="value", uuid="test-uuid")

    def test_warning_method(self, mock_structlog_logger):
        """Test warning method."""
        logger = BasicLogger(logger_uuid="test-uuid")
        logger.warning("Test warning message", extra_field="value")

        mock_structlog_logger.warning.assert_called_once_with("Test warning message", extra_field="value", uuid="test-uuid")

    def test_error_method(self, mock_structlog_logger):
        """Test error method."""
        logger = BasicLogger(logger_uuid="test-uuid")
        logger.error("Test error message", extra_field="value")

        mock_structlog_logger.error.assert_called_once_with("Test error message", extra_field="value", uuid="test-uuid")

    def test_critical_method(self, mock_structlog_logger):
        """Test critical method."""
        logger = BasicLogger(logger_uuid="test-uuid")
        logger.critical("Test critical message", extra_field="value")

        mock_structlog_logger.critical.assert_called_once_with("Test critical message", extra_field="value", uuid="test-uuid")

    def test_log_methods_without_kwargs(self, mock_structlog_logger):
        """Test all log methods without kwargs."""
        logger = BasicLogger(logger_uuid="test-uuid")

        # Test all methods without kwargs
        logger.info("Info message")
        logger.debug("Debug message")
        logger.warning("Warning message")
        logger.error("Error message")
        logger.critical("Critical message")

        mock_structlog_logger.info.assert_called_once_with("Info message", uuid="test-uuid")
        mock_structlog_logger.debug.assert_called_once_with("Debug message", uuid="test-uuid")
        mock_structlog_logger.warning.assert_called_once_with("Warning message", uuid="test-uuid")
        mock_structlog_logger.error.assert_called_once_with("Error message", uuid="test-uuid")
        mock_structlog_logger.critical.assert_called_once_with("Critical message", uuid="test-uuid")

    @patch("logging.basicConfig")
    def test_logging_basicconfig_called(self, mock_basicconfig):
        """Test that logging.basicConfig is called with correct parameters."""
        logger = BasicLogger(log_level=LogLevel.INFO)  # noqa: F841

        mock_basicconfig.assert_called_once_with(
            format="%(message)s",
            level=LogLevel.INFO.value,
        )

    def test_all_log_levels(self, mock_structlog_configure):
        """Test initialization with all log levels."""
        # Test all log levels
        for level in LogLevel:
            logger = BasicLogger(log_level=level)  # noqa: F841
            call_args = mock_structlog_configure.call_args[1]
            # Check that wrapper_class is the result of make_filtering_bound_logger
            assert "wrapper_class" in call_args
            assert callable(call_args["wrapper_class"])
            mock_structlog_configure.reset_mock()
