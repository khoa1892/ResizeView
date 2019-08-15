#import "ScreenLayoutData.h"
#define savedFrameKey @"savedFrameKey"
#define viewIdKey @"viewIdKey"
#define tagViewKey @"tagViewKey"
#define layoutObjectKey @"layoutObjectKey"
#define idOfChartKey @"idOfChartKey"
#define idOfQuickKey @"idOfQuickKey"
#define idOfRateSimpleKey @"idOfRateSimpleKey"
#define idOfRateMedKey @"idOfRateMedKey"
#define idOfRateSmallKey @"idOfRateSmallKey"
#define idOfPosOrderListKey @"idOfPosOrderListKey"
#define idOfNewsListPtKey @"idOfNewsListPtKey"
#define idOfNewsListLsKey @"idOfNewsListLsKey"

@implementation ScreenLayoutData
- (id)initWithId:(int)viewId
{
    self = [super init];
    if (self) {
        self.viewID = viewId;
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder{
//    [aCoder encodeDouble:self.ratioHeighOnView forKey:ratioHeighOnViewKey];
    [aCoder encodeCGRect:_savedFrame forKey:savedFrameKey];
    [aCoder encodeInteger:self.viewID forKey:viewIdKey];
    [aCoder encodeObject:self.tagView forKey:tagViewKey];
    [aCoder encodeObject:self.layoutObject forKey:layoutObjectKey];
    [aCoder encodeInt:self.idOfChart forKey:idOfChartKey];
    [aCoder encodeInt:self.idOfQuick forKey:idOfQuickKey];
    [aCoder encodeInt:self.idOfRateSimple forKey:idOfRateSimpleKey];
    [aCoder encodeInt:self.idOfRateMed forKey:idOfRateMedKey];
    [aCoder encodeInt:self.idOfRateSmall forKey:idOfRateSmallKey];
    [aCoder encodeInt:self.idOfPosOrderList forKey:idOfPosOrderListKey];
    [aCoder encodeInt:self.idOfNewsListPt forKey:idOfNewsListPtKey];
    [aCoder encodeInt:self.idOfNewsListLs forKey:idOfNewsListLsKey];
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    if(self){
        self.savedFrame =  [aDecoder decodeCGRectForKey:savedFrameKey];
        self.viewID = [aDecoder decodeIntForKey:viewIdKey];
        self.tagView = [aDecoder decodeObjectForKey:tagViewKey];
        self.layoutObject = [aDecoder decodeObjectForKey:layoutObjectKey];
        self.idOfChart = [aDecoder decodeIntForKey:idOfChartKey];
        self.idOfQuick = [aDecoder decodeIntForKey:idOfQuickKey];
        self.idOfRateSimple = [aDecoder decodeIntForKey:idOfRateSimpleKey];
        self.idOfRateMed = [aDecoder decodeIntForKey:idOfRateMedKey];
        self.idOfRateSmall = [aDecoder decodeIntForKey:idOfRateSmallKey];
        self.idOfPosOrderList = [aDecoder decodeIntForKey:idOfPosOrderListKey];
        self.idOfNewsListPt = [aDecoder decodeIntForKey:idOfNewsListPtKey];
        self.idOfNewsListLs = [aDecoder decodeIntForKey:idOfNewsListLsKey];
    }
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    ScreenLayoutData* data = [[ScreenLayoutData alloc] init];
    data.viewID = self.viewID;
    data.savedFrame = self.savedFrame;
    data.layoutObject = self.layoutObject;
    data.tagView = self.tagView;
    data.idOfChart = self.idOfChart;
    data.idOfQuick = self.idOfQuick;
    data.idOfRateSimple = self.idOfRateSimple;
    data.idOfRateMed = self.idOfRateMed;
    data.idOfRateSmall = self.idOfRateSmall;
    data.idOfPosOrderList = self.idOfPosOrderList;
    data.idOfNewsListPt = self.idOfNewsListPt;
    data.idOfNewsListLs = self.idOfNewsListLs;
    return data;
}


@end
