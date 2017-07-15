//
//  FSVideoEditorCommenData.h
//  FSVideoEditor
//
//  Created by 王明 on 2017/7/15.
//  Copyright © 2017年 Fission. All rights reserved.
//

#ifndef FSVideoEditorCommenData_h
#define FSVideoEditorCommenData_h

#define FSHexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define FSHexRGBAlpha(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define AddressAPI  [[[NSUserDefaults standardUserDefaults] valueForKey:@"Country"] isEqualToString:@"ar"] ? @"http://www.7nujoom.com/" : @"http://www.haahi.com/"
#define AddressIP  [[[NSUserDefaults standardUserDefaults] valueForKey:@"Country"] isEqualToString:@"ar"] ? @"http://10.10.32.145:8086/" : @"http://52.28.46.170/"


#endif /* FSVideoEditorCommenData_h */
