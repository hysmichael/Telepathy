//
//  ClockWidgetController.m
//  Telepathy
//
//  Created by Michael Hong on 4/25/15.
//  Copyright (c) 2015 Michael Hong. All rights reserved.
//

#import "ClockWidgetController.h"
#import <CZWeatherKit.h>
#import "DateFormats.h"

#define kWeatherServiceKey @"2b9008dbfb034717"

@implementation ClockWidgetController {
    NSString *rawCityStr;
    NSString *rawTemperatureStr;
    CLLocation *partnerLocation;
    BOOL weatherRequested;
}

- (instancetype)initWithViewFrame:(NSRect)frame parentView:(NSView *)parentView {
    self = [super init];
    if (self) {
        self.view = [[ClockWidgetView alloc] initWithFrame:frame];
        [parentView addSubview:self.view];

        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        
        rawCityStr = @"Unknown";
        rawTemperatureStr = @" -°";
        [self updateCityTemperatureLabel];
        
        weatherRequested = false;
    }
    return self;
}

- (void) updateClockWidget {
    [self updateProfileImage];
    [self updateDatetimeComponent];
    [self updateGeoCity];
    [self updateWeather];
    [self updateGeoLocationAndDistance];
}

- (void) updateDatetimeComponent {
    NSDate *partnerTime = [[DataManager sharedManager] convertDateFromSelfTimezoneToPartnerTimezone:[NSDate date]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormatTimeAndDate];
    NSString *rawDateStr1 = [dateFormatter stringFromDate:partnerTime];
    [dateFormatter setDateFormat:dateFormatWeekday];
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
    if (weatherRequested) {
        NSDate *timeStamp = [[DataManager sharedManager] userSelf][@"weatherTimestamp"];
        if (timeStamp && [[NSDate date] timeIntervalSinceDate:timeStamp] < 60) return;
    }
    CZWeatherRequest *request = [CZWeatherRequest requestWithType:CZCurrentConditionsRequestType];
    request.location = [CZWeatherLocation locationWithCLLocation:partnerLocation];
    request.service = [CZWundergroundService serviceWithKey:kWeatherServiceKey];
    [request performRequestWithHandler:^(id data, NSError *error) {
        if (data) {
            CZWeatherCondition *current = (CZWeatherCondition *)data;
            self.view.weatherIconLabel.stringValue = [NSString stringWithFormat:@"%c", current.climaconCharacter];
            rawTemperatureStr = [NSString stringWithFormat:@" %.0f°", current.temperature.c];
            [self updateCityTemperatureLabel];
            weatherRequested = true;
            [[DataManager sharedManager] userSelf][@"weatherTimestamp"] = [NSDate date];
        }
    }];
}

- (void) updateCityTemperatureLabel {
    NSMutableAttributedString *cityTempStr = [[NSMutableAttributedString alloc] initWithString:rawCityStr attributes:@{NSForegroundColorAttributeName: [TPColor defaultBlack]}];
    NSAttributedString *atrTempStr = [[NSAttributedString alloc] initWithString:rawTemperatureStr attributes:@{NSForegroundColorAttributeName: [TPColor mediumGray]}];
    [cityTempStr appendAttributedString:atrTempStr];
    [self.view.cityLabel setAttributedStringValue:cityTempStr];
}

- (void) updateGeoLocationAndDistance {
    if ([[DataManager sharedManager] needsUpdateSelfCurrentLocation]) {
        [self.locationManager startUpdatingLocation];
    } else {
        [self updateDistanceLabel];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation *location = [locations lastObject];
    [[DataManager sharedManager] updateSelfCurrentLocation:location];
    [manager stopUpdatingLocation];
    [self updateDistanceLabel];
}

- (void) updateDistanceLabel {
    CLLocationDistance distance = [[DataManager sharedManager] distanceBetween];
    self.view.distanceLabel.stringValue = [NSString stringWithFormat:@"%.0f km", distance / 1000];
}

@end
