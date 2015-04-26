//
//  ClockWidgetController.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "ClockWidgetController.h"
#import <CZWeatherKit.h>

#define dateFormatString1 @"HH:mm・MMM dd "
#define dateFormatString2 @"(E)"

#define kWeatherServiceKey @"2b9008dbfb034717"

@implementation ClockWidgetController {
    NSString *rawCityStr;
    NSString *rawTemperatureStr;
    CLLocation *partnerLocation;
}

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        self.view = [[ClockWidgetView alloc] initWithFrame:frame];
        [parentView addSubview:self.view];

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        rawCityStr = [NSString new];
        rawTemperatureStr = [NSString new];
    }
    return self;
}

- (void) updateClockWidget {
    [self updateProfileImage];
    [self updateDatetimeComponent];
    [self updateGeoCity];
    [self updateWeather];
    [self updateDistance];
}

- (void) updateDatetimeComponent {
    NSDate *partnerTime = [[DataManager sharedManager] convertDateFromSelfTimezoneToPartnerTimezone:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatString1];
    NSString *rawDateStr1 = [dateFormatter stringFromDate:partnerTime];
    [dateFormatter setDateFormat:dateFormatString2];
    NSString *rawDateStr2 = [dateFormatter stringFromDate:partnerTime];
    
    NSMutableAttributedString *datetimeStr = [[NSMutableAttributedString alloc] init];
    NSAttributedString *attrDateStr1 = [[NSAttributedString alloc] initWithString:rawDateStr1 attributes:@{NSFontAttributeName: [NSFont TPFontWithSize:18.0]}];
    NSAttributedString *attrDateStr2 = [[NSAttributedString alloc] initWithString:rawDateStr2 attributes:@{NSFontAttributeName: [NSFont TPFontWithSize:12.0]}];
    [datetimeStr appendAttributedString:attrDateStr1];
    [datetimeStr appendAttributedString:attrDateStr2];
    
    [self.view.timeLabel setAttributedStringValue:datetimeStr];
}

- (void) updateProfileImage {
    [[DataManager sharedManager] getPartnerProfileImage:^(NSImage *image) {
        self.view.profileImageView.image = image;
    }];
    if ([[DataManager sharedManager] isPartnerActive]) {
        self.view.profileImageView.layer.borderColor = [TPColor green].CGColor;
    } else {
        self.view.profileImageView.layer.borderColor = [NSColor grayColor].CGColor;
    }
}

- (void) updateGeoCity {
    partnerLocation = [[DataManager sharedManager] getPartnerLocation:^(CLPlacemark *placemark) {
        rawCityStr = placemark.locality;
        [self updateCityTemperatureLabel];
    }];
}

- (void) updateWeather {
    CZWeatherRequest *request = [CZWeatherRequest requestWithType:CZCurrentConditionsRequestType];
    request.location = [CZWeatherLocation locationWithCLLocation:partnerLocation];
    request.service = [CZWundergroundService serviceWithKey:kWeatherServiceKey];
    [request performRequestWithHandler:^(id data, NSError *error) {
        if (data) {
            CZWeatherCondition *current = (CZWeatherCondition *)data;
            self.view.weatherIconLabel.stringValue = [NSString stringWithFormat:@"%c", current.climaconCharacter];
            rawTemperatureStr = [NSString stringWithFormat:@"  %.0f°", current.temperature.c];
            [self updateCityTemperatureLabel];
        }
    }];
}

- (void) updateCityTemperatureLabel {
    NSMutableAttributedString *cityTempStr = [[NSMutableAttributedString alloc] initWithString:rawCityStr attributes:@{NSForegroundColorAttributeName: [TPColor defaultBlack]}];
    NSAttributedString *atrTempStr = [[NSAttributedString alloc] initWithString:rawTemperatureStr attributes:@{NSForegroundColorAttributeName: [TPColor darkGray]}];
    [cityTempStr appendAttributedString:atrTempStr];
    [self.view.cityLabel setAttributedStringValue:cityTempStr];
}

- (void) updateDistance {
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    [[DataManager sharedManager] updateSelfCurrentCoordinates:location.coordinate];
    [manager stopUpdatingLocation];
    CLLocationDistance distance = [[DataManager sharedManager] distanceBetween];
    self.view.distanceLabel.stringValue = [NSString stringWithFormat:@"%.0f km", distance / 1000];
}

@end
