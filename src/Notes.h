#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, NoteError) {
    NoteErrorNone = 0,
    NoteErrorStorage = 1,
    NoteErrorNotFound = 2,
};

/**
 * A single note: title, content, creation/update timestamps, and a stable
 * integer identifier.
 */
@interface Note : NSObject

@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *content;
@property (nonatomic, copy, readonly) NSDate *createdAt;
@property (nonatomic, copy, readonly) NSDate *updatedAt;
@property (nonatomic, assign, readonly) NSInteger identifier;

/**
 * Designated initializer.
 */
- (instancetype)initWithIdentifier:(NSInteger)identifier
                             title:(NSString *)title
                           content:(NSString *)content
                       createdAt:(NSDate *)createdAt
                       updatedAt:(NSDate *)updatedAt NS_DESIGNATED_INITIALIZER;

/**
 * Return a copy of this note with updated content and timestamp.
 */
- (Note *)noteWithUpdatedContent:(NSString *)content updatedAt:(NSDate *)updatedAt;

/**
 * JSON-friendly dictionary representation.
 */
- (NSDictionary *)dictionaryRepresentation;

/**
 * Create a note from a dictionary (as loaded from JSON).
 */
+ (Note *)noteWithDictionary:(NSDictionary *)dict;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

/**
 * Notes store: create, read, update, delete notes persisted to a JSON file.
 *
 * Thread-safety: not thread-safe; intended for single-user macOS desktop use.
 */
@interface Notes : NSObject

/**
 * Shared store backed by ~/Library/Application Support/SHAE/notes.json.
 */
+ (instancetype)sharedManager;

/**
 * Initialize with a custom storage file path (used for testing/config).
 */
- (instancetype)initWithStorageFile:(NSString *)path NS_DESIGNATED_INITIALIZER;

/**
 * All notes, newest by updatedAt first.
 */
- (NSArray<Note *> *)allNotes;

/**
 * Find a note by identifier, or nil if not present.
 */
- (Note *)noteWithIdentifier:(NSInteger)identifier;

/**
 * Create a new note. Returns nil and populates *error on failure.
 */
- (Note *)createNoteWithTitle:(NSString *)title
                      content:(NSString *)content
                         error:(NSError **)error;

/**
 * Update an existing note by reference. Returns NO and populates *error if
 * the note is not in the store.
 */
- (BOOL)updateNote:(Note *)note
              title:(NSString *)title
            content:(NSString *)content
               error:(NSError **)error;

/**
 * Delete a note by identifier. Returns NO and populates *error if not found.
 */
- (BOOL)deleteNoteWithIdentifier:(NSInteger)identifier
                            error:(NSError **)error;

/**
 * Persist all notes to the given path as JSON. Returns NO on failure.
 */
- (BOOL)saveToFile:(NSString *)path error:(NSError **)error;

/**
 * Load notes from the given path. Returns YES if the file does not exist
 * (empty store is valid).
 */
- (BOOL)loadFromFile:(NSString *)path error:(NSError **)error;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
