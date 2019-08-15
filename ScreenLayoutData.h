#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ScreenLayoutData : NSObject<NSCoding,NSCopying>
@property int viewID;
@property (nonatomic, strong) NSString *tagView;
@property (nonatomic, strong) NSObject *layoutObject;
@property int idOfChart;
@property int idOfQuick;
@property int idOfRateSimple;
@property int idOfRateMed;
@property int idOfRateSmall;
@property int idOfPosOrderList;
@property int idOfNewsListPt;
@property int idOfNewsListLs;
@property CGRect savedFrame;
- (instancetype)initWithId:(int)viewId;
@end
