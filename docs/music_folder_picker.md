**DOD:**
1. User can pick a folder from its system
2. All supported (by miniaudio) files are fetch from the folder
3. Folder is saved so user can see it after restarting the application

**UI**
1. cut in stone UI approach
2. Implement UI screen in non picked state
3. Implement button for picking folder
4. Implement UI screen in empty picked state
5. Implement UI screen in non empty picked state
6. UI should be adapted for both phones and desktop
7. Reload button should sync folder state with application state
8. Project at this point should run on macOS, iOS, iPadOS, Android

**Backend**:
1. Research approaches to architecture of this module (objects, connections, etc.)
2. There is an interface that starts flow:
	1. Picks folder
	2. interface that accepts folder url and give back list of songs
	3. interface for saving picked folder
3. Interface for syncing folder state with application state