#import "Notes.h"

@implementation Note
@synthesize identifier = _identifier;
@synthesize title = _title;
@synthesize content = _content;
@synthesize createdAt = _createdAt;
@synthesize updatedAt = _updatedAt;

- (instancetype)initWithIdentifier:(NSInteger)identifier
                             title:(NSString *)title
                           content:(NSString *)content
                       createdAt:(NSDate *)createdAt
                       updatedAt:(NSDate *)updatedAt
{
    self = [super init];
    if (self) {
        _identifier = identifier;
        _title = [title copy];
        _content = [content copy];
        _createdAt = [createdAt copy];
        _updatedAt = [updatedAt copy];
    }
    return self;
}

- (Note *)noteWithUpdatedContent:(NSString *)content updatedAt:(NSDate *)updatedAt
{
    return [[Note alloc] initWithIdentifier:self.identifier
                                     title:self.title
                                   content:content
                               createdAt:self.createdAt
                               updatedAt:updatedAt];
}

- (NSDictionary *)dictionaryRepresentation
{
    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    return @{
        @"identifier": @(self.identifier),
        @"title": self.title,
        @"content": self.content,
        @"createdAt": [formatter stringFromDate:self.createdAt],
        @"updatedAt": [formatter stringFromDate:self.updatedAt],
    };
}

+ (Note *)noteWithDictionary:(NSDictionary *)dict
{
    NSISO8601DateFormatter *formatter = [[NSISO8601DateFormatter alloc] init];
    NSInteger identifier = [dict[@"identifier"] integerValue];
    NSDate *createdAt = [formatter dateFromString:dict[@"createdAt"]];
    if (!createdAt) createdAt = [NSDate date];
    NSDate *updatedAt = [formatter dateFromString:dict[@"updatedAt"]];
    if (!updatedAt) updatedAt = [NSDate date];
    return [[Note alloc] initWithIdentifier:identifier
                                     title:dict[@"title"] ?: @""
                                   content:dict[@"content"] ?: @""
                               createdAt:createdAt
                               updatedAt:updatedAt];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<Note %ld: %@>", (long)self.identifier, self.title];
}
@end

@implementation Notes
{
    NSString *_storagePath;
    NSMutableArray<Note *> *_notes;
}

+ (instancetype)sharedManager
{
    static Notes *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory,
                                                             NSUserDomainMask, YES);
        NSString *dir = [paths firstObject];
        if (!dir) dir = NSHomeDirectory();
        dir = [dir stringByAppendingPathComponent:@"SHAE"];
        NSError *dirError = nil;
        [[NSFileManager defaultManager] createDirectoryAtPath:dir
                                     withIntermediateDirectories:YES
                                              attributes:nil
                                               error:&dirError];
        shared = [[Notes alloc] initWithStorageFile:[dir stringByAppendingPathComponent:@"notes.json"]];
    });
    return shared;
}

- (instancetype)initWithStorageFile:(NSString *)path
{
    self = [super init];
    if (self) {
        _storagePath = [path copy];
        _notes = [NSMutableArray array];
        NSError *loadError = nil;
        [self loadFromFile:_storagePath error:&loadError];
        // An absent or unreadable store is not fatal: start empty.
    }
    return self;
}

- (NSArray<Note *> *)allNotes
{
    NSArray *sorted = [_notes sortedArrayUsingComparator:^NSComparisonResult(Note *a, Note *b) {
        return [b.updatedAt compare:a.updatedAt];
    }];
    return [sorted copy];
}

- (Note *)noteWithIdentifier:(NSInteger)identifier
{
    for (Note *note in _notes) {
        if (note.identifier == identifier) {
            return note;
        }
    }
    return nil;
}

- (NSInteger)nextIdentifier
{
    NSInteger maxId = 0;
    for (Note *note in _notes) {
        if (note.identifier > maxId) {
            maxId = note.identifier;
        }
    }
    return maxId + 1;
}

- (Note *)createNoteWithTitle:(NSString *)title
                      content:(NSString *)content
                         error:(NSError **)error
{
    if (!title || [title length] == 0) {
        if (error) {
            *error = [NSError errorWithDomain:@"NotesErrorDomain"
                                         code:NoteErrorNone
                                     userInfo:@{NSLocalizedDescriptionKey: @"Title is required."}];
        }
        return nil;
    }

    NSDate *now = [NSDate date];
    Note *note = [[Note alloc] initWithIdentifier:[self nextIdentifier]
                                           title:title
                                         content:content
                                     createdAt:now
                                     updatedAt:now];
    [_notes addObject:note];

    NSError *saveError = nil;
    if (![self saveToFile:_storagePath error:&saveError]) {
        if (error) {
            *error = saveError;
        }
        return nil;
    }
    return note;
}

- (BOOL)updateNote:(Note *)note
              title:(NSString *)title
            content:(NSString *)content
               error:(NSError **)error
{
    NSUInteger index = [_notes indexOfObjectIdenticalTo:note];
    if (index == NSNotFound) {
        if (error) {
            *error = [NSError errorWithDomain:@"NotesErrorDomain"
                                         code:NoteErrorNotFound
                                     userInfo:@{NSLocalizedDescriptionKey: @"Note not found."}];
        }
        return NO;
    }

    NSDate *now = [NSDate date];
    Note *updated = [note noteWithUpdatedContent:content updatedAt:now];
    _notes[index] = updated;

    NSError *saveError = nil;
    if (![self saveToFile:_storagePath error:&saveError]) {
        if (error) {
            *error = saveError;
        }
        return NO;
    }
    return YES;
}

- (BOOL)deleteNoteWithIdentifier:(NSInteger)identifier
                            error:(NSError **)error
{
    NSUInteger found = NSNotFound;
    for (NSUInteger i = 0; i < _notes.count; i++) {
        if (((Note *)_notes[i]).identifier == identifier) {
            found = i;
            break;
        }
    }
    if (found == NSNotFound) {
        if (error) {
            *error = [NSError errorWithDomain:@"NotesErrorDomain"
                                         code:NoteErrorNotFound
                                     userInfo:@{NSLocalizedDescriptionKey: @"Note not found."}];
        }
        return NO;
    }

    [_notes removeObjectAtIndex:found];

    NSError *saveError = nil;
    if (![self saveToFile:_storagePath error:&saveError]) {
        if (error) {
            *error = saveError;
        }
        return NO;
    }
    return YES;
}

- (BOOL)saveToFile:(NSString *)path error:(NSError **)error
{
    NSMutableArray *dicts = [NSMutableArray arrayWithCapacity:_notes.count];
    for (Note *note in _notes) {
        [dicts addObject:[note dictionaryRepresentation]];
    }

    NSError *serializationError = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dicts
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&serializationError];
    if (!data) {
        if (error) {
            *error = serializationError
                ?: [NSError errorWithDomain:@"NotesErrorDomain"
                                     code:NoteErrorStorage
                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to serialize notes."}];
        }
        return NO;
    }

    NSString *dir = [path stringByDeletingLastPathComponent];
    NSError *dirError = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:dir
                                             withIntermediateDirectories:YES
                                              attributes:nil
                                               error:&dirError]) {
        if (error) {
            *error = dirError;
        }
        return NO;
    }

    BOOL wrote = [data writeToFile:path
                           options:NSDataWritingAtomic
                             error:error];
    return wrote;
}

- (BOOL)loadFromFile:(NSString *)path error:(NSError **)error
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return YES; // nothing to load; empty store is valid
    }

    NSData *data = [NSData dataWithContentsOfFile:path];
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:@"NotesErrorDomain"
                                         code:NoteErrorStorage
                                     userInfo:@{NSLocalizedDescriptionKey: @"Failed to read notes file."}];
        }
        return NO;
    }

    NSError *serializationError = nil;
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data
                                                     options:0
                                                       error:&serializationError];
    if (!array || ![array isKindOfClass:[NSArray class]]) {
        if (error) {
            *error = serializationError
                ?: [NSError errorWithDomain:@"NotesErrorDomain"
                                     code:NoteErrorStorage
                                 userInfo:@{NSLocalizedDescriptionKey: @"Failed to parse notes."}];
        }
        return NO;
    }

    _notes = [NSMutableArray arrayWithCapacity:array.count];
    for (NSDictionary *dict in array) {
        if ([dict isKindOfClass:[NSDictionary class]]) {
            [_notes addObject:[Note noteWithDictionary:dict]];
        }
    }
    return YES;
}

@end
