//
//  FSFileDBManager.m
//  FSUploadDemo
//
//  Created by Charles on 2017/5/18.
//  Copyright © 2017年 Fission. All rights reserved.
//

#import "FSFileUploadDBManager.h"
#import "FMDB.h"
#import <objc/runtime.h>
#import "FSMD5Utils.h"
#import "FSFileSlice.h"
static id object = nil;
@implementation FSFileUploadDBManager
+(FSFileUploadDBManager *)shareDBManager{
    return [[FSFileUploadDBManager alloc] init];
}
-(instancetype)init{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!object) {
            object = [super init];
        }
    });
    return object;
}
+(id)allocWithZone:(struct _NSZone *)zone{
    return object;
}
-(id)copyWithZone:(NSZone *)zone{
    return object;
}
+(NSArray *)unUploadFilesWithKey:(NSString *)cacheKey{
    if (cacheKey == nil) {
        return nil;
    }
    FMDatabase *dataBase = [FSFileUploadDBManager creatUploadTable];
    if (![dataBase open]) {
        return nil;
    }
    NSString *md5Value = [FSMD5Utils getFileMD5WithPath:cacheKey];
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_Upload WHERE md5Value = '%@' AND state = 1",md5Value];
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    
    NSMutableArray *slices = [NSMutableArray array];
    
    while ([resultSet next]) {
        NSInteger trunks = [resultSet intForColumn:@"trunks"];
        NSInteger fileTrunk = [resultSet intForColumn:@"fileTrunk"];
        NSString *range = [resultSet stringForColumn:@"fileRange"];
        NSInteger fileId = [resultSet intForColumn:@"fileId"];
        long long totalSize = [resultSet longLongIntForColumn:@"totalSize"];
        BOOL state = [resultSet boolForColumn:@"state"];
        long long fileSize = [resultSet longLongIntForColumn:@"fileSize"];
        NSString *fileName = [resultSet stringForColumn:@"fileName"];
        
        FSFileSlice *slice = [[FSFileSlice alloc] init];
        slice.trunks = trunks;
        slice.fileRange = NSRangeFromString(range);
        slice.fileId = fileId;
        slice.totalSize = totalSize;
        slice.state = state;
        slice.fileTrunk = fileTrunk;
        slice.fileName = fileName;
        slice.fileSize = fileSize;
        [slices addObject:slice];
    }
    [dataBase close];

    return [slices count]?slices:nil;
}

+(void)insertWillUploadFiles:(NSString *)cacheKey files:(NSArray *)files{
    if (cacheKey == nil) {
        return ;
    }
    if ([files count] == 0) {
        return;
    }
    
    FMDatabase *db = [FSFileUploadDBManager creatUploadTable];
    if (![db open]) {
        return;
    }
    

    NSString *md5Value = [FSMD5Utils getFileMD5WithPath:cacheKey];
    // if not exists (select phone from t where phone= '1')
    NSString *willInsert = [NSString stringWithFormat:@"REPLACE INTO t_Upload(id,trunks,fileTrunk,fileRange,fileId,totalSize,state,md5Value,fileName,fileSize) "];
    
    [files enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        FSFileSlice *slice = (FSFileSlice *)obj;
        NSString *primaryKey = [NSString stringWithFormat:@"%@-%ld",md5Value,slice.fileId];
//        NSString *ifNoExist = [NSString stringWithFormat:@"IF NOT EXISTS (SELECT * FROM t_Upload WHERE id = '%@')",primaryKey];
        NSString *info = [NSString stringWithFormat:@"VALUES('%@',%ld,%ld,'%@',%ld,%ld,%d,'%@','%@',%f)",primaryKey,slice.trunks,slice.fileTrunk,NSStringFromRange(slice.fileRange),slice.fileId,(long)slice.totalSize,slice.state,md5Value,slice.fileName,slice.fileSize];
//        NSString *onDuplicateKe = [NSString stringWithFormat:@"ON DUPLICATE KEY UPDATE fileName = '%@'",slice.fileName]
//        NSString *sql = [NSString stringWithFormat:@"%@ %@ %@",ifNoExist,willInsert,info];
        NSString *sql = [NSString stringWithFormat:@"%@ %@",willInsert,info];

        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"sql-faild:%@",sql);
        }
    }];
    

    [db close];
}
+(void)insertCompleteInfo:(NSString *)cacheKey{
    
    if (cacheKey == nil) {
        return ;
    }
    FMDatabase *dataBase = [FSFileUploadDBManager creatCompleteTable];
    if (![dataBase open]) {
        return;
    }
    NSString *updateSql = [NSString stringWithFormat:@"INSERT INTO t_Complete (fileName,md5Key,filePath) VALUES('%@','%@','%@');",[cacheKey lastPathComponent],[FSMD5Utils getFileMD5WithPath:cacheKey],cacheKey];
    BOOL success = [dataBase executeUpdate:updateSql];
    [dataBase close];
    if (!success) {
        NSLog(@"updateSql:%@",updateSql);
    }
}
+(void)fileUploadSuccessUpdate:(FSFileSlice *)slice cacheKey:(NSString *)cacheKey{
    if (cacheKey == nil) {
        return ;
    }
    FMDatabase *dataBase = [FSFileUploadDBManager creatCompleteTable];
    if (![dataBase open]) {
        return;
    }
    
    NSString *md5Value = [FSMD5Utils getFileMD5WithPath:cacheKey];
    NSString *primaryKey = [NSString stringWithFormat:@"%@-%ld",md5Value,(long)slice.fileId];

//    NSString *sql = [NSString stringWithFormat:@"UPDATE t_Upload state SET t_Upload.state = 1 WHERE t_Upload.md5Value = '%@' AND t_Upload.fildId = %ld",md5Value,slice.fileId];               222         ``
    NSString *sql = [NSString stringWithFormat:@"UPDATE t_Upload SET state = 1 WHERE id = '%@';",primaryKey];

    BOOL success = [dataBase executeUpdate:sql];
    if (!success) {
        NSLog(@"sql:%@",sql);
    }
    [dataBase close];
}
+(BOOL)fileUploadStateWithCacheKey:(NSString *)cacheKey{
    if (cacheKey == nil) {
        return NO;
    }
    FMDatabase *dataBase = [FSFileUploadDBManager creatCompleteTable];
    if (![dataBase open]) {
        return NO;
    }
    NSString *md5Value = [FSMD5Utils getFileMD5WithPath:cacheKey];
    
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_Complete WHERE md5Key = '%@' AND fileName = '%@';",md5Value,[cacheKey lastPathComponent]];

    FMResultSet *result = [dataBase executeQuery:sql];
    BOOL haveValue = [result next];
    [dataBase close];

    return haveValue;
}
+(NSArray *)filesAnyUploadCompleted{
    FMDatabase *dataBase = [FSFileUploadDBManager creatCompleteTable];
    if (![dataBase open]) {
        return nil;
    }
     FMResultSet *allResult = [dataBase executeQuery:@"SELECT * FROM t_Complete"];
     while ([allResult next]) {
     NSLog(@"%@ %@ %@",[allResult stringForColumn:@"md5Key"],[allResult stringForColumn:@"fileName"],[allResult stringForColumn:@"filePath"]);
     }
    
    return nil;
}
+(FMDatabase *)creatCompleteTable{
    NSString *path = [FSFileUploadDBManager uploadInfoDBPath];
    FMDatabase *dataBase = [FMDatabase databaseWithPath:path];
    if (![dataBase open]) {
        return dataBase;
    }
    [dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS t_Complete (id text PRIMARY KEY, fileName text NOT NULL, md5Key text NOT NULL,filePath text);"];
    return dataBase;
}
+(FMDatabase *)creatUploadTable{
    
    NSString *path = [FSFileUploadDBManager uploadInfoDBPath];
    FMDatabase *db = [FMDatabase databaseWithPath:path];
    if (![db open]) {
        return db;
    }
    [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_Upload (id text PRIMARY KEY, trunks integer, fileTrunk integer , fileRange text,fileId integer,totalSize biginteger,state bool,md5Value text,fileName text,fileSize bigInteger);"];
    return db;
}
+(NSString *)uploadInfoDBPath{
    NSString *dbDirPath = [FSFileUploadDBManager dbDirectoryPath];
    NSString *dbPath = [dbDirPath stringByAppendingString:@"/uploadInfo.db"];
    return dbPath;
}
+(NSString *)dbDirectoryPath{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [paths objectAtIndex:0];
    NSString *dbDirPath = [docDir stringByAppendingPathComponent:@"db"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectiory;
    if (![fileManager fileExistsAtPath:dbDirPath isDirectory:&isDirectiory]) {
        [fileManager createDirectoryAtPath:dbDirPath withIntermediateDirectories:YES attributes:@{NSFileCreationDate:[NSDate date]} error:nil];
    }
    
    return dbDirPath;
}
@end
