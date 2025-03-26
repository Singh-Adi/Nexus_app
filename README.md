A Flutter mobile client for the Nexus social network.

## Getting Started

This project is a mobile client for a social networking platform with Twitter-like features including user authentication, tweet feeds, profiles, likes, comments, and notifications.

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- An Android or iOS device/emulator

### Installation

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app on your device/emulator

## Testing

The app includes different types of tests:

- **Unit Tests**: Tests individual functions and classes
- **Widget Tests**: Tests UI components in isolation
- **Integration Tests**: Tests the whole app in a simulated environment
## Features

- User authentication (login/register)
- Tweet feed with refresh capability
- User profiles
- Creating/liking/retweeting posts
- Notifications
- Search functionality
- Direct messaging

## Mock Mode

For development without a backend, the app includes a mock service that simulates API responses.
The default test credentials are:

- Username: testuser
- Password: password123

## Architecture

The app follows a Provider-based architecture with the following components:

- **Models**: Data structures for the app
- **Providers**: State management classes
- **Services**: Backend communication and business logic
- **Screens**: UI components
- **Widgets**: Reusable UI elements

## License

This project is licensed under the MIT License - see the LICENSE file for details.
EOL

# Create a shell script to run all tests
echo -e "\n${BLUE}Creating test runner script...${NC}"
cat > run_tests.sh << 'EOL'
#!/bin/bash
# Script to run all tests for Nexus Mobile

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Nexus Mobile Test Runner ===${NC}"

# Run unit tests
echo -e "\n${YELLOW}Running unit tests...${NC}"
flutter test test/unit/
UNIT_RESULT=$?

# Run widget tests
echo -e "\n${YELLOW}Running widget tests...${NC}"
flutter test test/widget/
WIDGET_RESULT=$?

# Run integration tests
echo -e "\n${YELLOW}Running integration tests...${NC}"
flutter test integration_test/
INTEGRATION_RESULT=$?

# Report results
echo -e "\n${BLUE}=== Test Results ===${NC}"
[ $UNIT_RESULT -eq 0 ] && echo -e "${GREEN}Unit Tests: PASSED${NC}" || echo -e "${RED}Unit Tests: FAILED${NC}"
[ $WIDGET_RESULT -eq 0 ] && echo -e "${GREEN}Widget Tests: PASSED${NC}" || echo -e "${RED}Widget Tests: FAILED${NC}"
[ $INTEGRATION_RESULT -eq 0 ] && echo -e "${GREEN}Integration Tests: PASSED${NC}" || echo -e "${RED}Integration Tests: FAILED${NC}"

# Overall status
if [ $UNIT_RESULT -eq 0 ] && [ $WIDGET_RESULT -eq 0 ] && [ $INTEGRATION_RESULT -eq 0 ]; then
echo -e "\n${GREEN}All tests passed!${NC}"
exit 0
else
echo -e "\n${RED}Some tests failed!${NC}"
exit 1
fi