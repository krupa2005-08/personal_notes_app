# Personal Notes App (Flutter)

This is a simple, locally-stored notes application built with Flutter. It allows users to create, read, update, and delete notes, which are saved on the device.

## App Structure

The application is structured into a few key directories to keep the code organized and maintainable:

-   `lib/main.dart`: The entry point of the application. It handles the initialization of the **Hive** database and sets up the app's theme, including support for dark mode.
-   `lib/models/`: Contains the data model for the application. The `note.dart` file defines the `Note` object with its properties (`title`, `description`, `createdAt`) and includes the necessary annotations for the **Hive** type adapter generation.
-   `lib/screens/`: This directory holds the UI for each screen of the app.
    -   `home_screen.dart`: Displays a list of all saved notes and includes a search bar. It uses a `ValueListenableBuilder` to efficiently listen for and reflect changes in the database.
    -   `add_edit_note_screen.dart`: A single screen used for both adding a new note and editing an existing one. It contains a form with `TextField`s for the title and description.

## Implementation Details

-   **Local Storage**: I chose **Hive** for local persistence. It's a fast, lightweight NoSQL database for Dart and Flutter. It's more suitable than `SharedPreferences` for this use case because it can store custom Dart objects directly (via `TypeAdapter`s) without manual JSON serialization/deserialization.
-   **State Management**: For simplicity, the app primarily uses `StatefulWidget` and `setState`. On the home screen, `ValueListenableBuilder` is used to reactively build the UI from the Hive box, which is an efficient pattern that reduces boilerplate code.
-   **CRUD Operations**:
    -   **Create**: A new note is added using `box.add(newNote)` on the Add/Edit screen.
    -   **Read**: Notes are read from the Hive box and displayed in a `ListView` on the Home screen.
    -   **Update**: Tapping a note navigates to the Add/Edit screen in "edit mode," and the note is updated using `box.putAt(index, updatedNote)`.
    -   **Delete**: Notes can be deleted by swiping them away on the home screen, which is implemented using the `Dismissible` widget.
-   **Bonus Features**:
    -   **Search**: A search bar is implemented on the home screen to filter notes by their title in real-time.
    -   **Dark Mode**: The app respects the system's theme setting by configuring both `theme` and `darkTheme` in `MaterialApp`.
    -   **Animations**: Simple, clean animations for adding/deleting notes are provided out-of-the-box by `ListView.builder` and the `Dismissible` widget.

## Challenges and Solutions

A key challenge when working with local databases like Hive is the initial setup. It requires several steps: adding multiple dependencies (`hive`, `hive_flutter`, `build_runner`), creating a model with specific annotations, and running a code generator to create the `TypeAdapter`. To solve this, I followed the Hive documentation carefully, ensuring the `part` directive was correct and that the `build_runner` command was executed successfully.

Another consideration was how to update the UI efficiently when data changes. Instead of manually fetching data and calling `setState` everywhere, I leveraged the `ValueListenableBuilder` widget provided by `hive_flutter`. This simplified the home screen's logic significantly, as it automatically listens to the Hive box and rebuilds the `ListView` only when necessary.