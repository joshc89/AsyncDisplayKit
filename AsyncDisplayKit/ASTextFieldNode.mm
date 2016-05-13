//
//  ASTextFieldNode.m
//  AsyncDisplayKit
//
//  Created by Josh Campion on 13/05/2016.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import "ASTextFieldNode.h"

//#import <objc/message.h>

// #import "ASDisplayNode+Subclasses.h"
//#import "ASEqualityHelpers.h"
//#import "ASTextNodeWordKerner.h"
//#import "ASThread.h"

@interface  ASTextFieldNode ()
{
  @private
  ASDN::RecursiveMutex _textFieldLock;
  
  NSDictionary *_defaultPlaceholderAttributes;
}

@end

@implementation ASTextFieldNode

#pragma mark - Initialisers

- (instancetype)init
{
  UITextField *_textField = [[UITextField alloc] init];
  ASDisplayNodeViewBlock textFieldViewBlock = ^UIView *{
    return _textField;
  };
  
  if (self = [super initWithViewBlock:textFieldViewBlock]) {
    
    _autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _autocorrectionType = UITextAutocorrectionTypeDefault;
    _spellCheckingType = UITextSpellCheckingTypeDefault;
    _keyboardType = UIKeyboardTypeDefault;
    _keyboardAppearance = UIKeyboardAppearanceDefault;
    _returnKeyType = UIReturnKeyDefault;
    
    return  self;
  }
  
  return nil;
}

- (instancetype)initWithLayerBlock:(ASDisplayNodeLayerBlock)viewBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock
{
  ASDisplayNodeAssertNotSupported();
  return nil;
}

- (instancetype)initWithViewBlock:(ASDisplayNodeViewBlock)viewBlock didLoadBlock:(ASDisplayNodeDidLoadBlock)didLoadBlock
{
  ASDisplayNodeAssertNotSupported();
  return nil;
}

#pragma mark - ASDisplayNode Overrides

-(void)didLoad
{
  [super didLoad];
  
  ASDN::MutexLocker l(_textFieldLock);
  
  // assign the ASDisplayNode properties
  self.textField.backgroundColor = self.backgroundColor;
  self.textField.opaque = self.opaque;
  
  // assign the text properties
  if (self.defaultTextAttributes != nil) {
    self.textField.defaultTextAttributes = self.defaultTextAttributes;
  } else {
    self.defaultTextAttributes = self.textField.defaultTextAttributes;
  }
  
  if (self.attributedText != nil) {
    self.textField.attributedText = self.attributedText;
  } else if (self.text != nil) {
    self.textField.text = self.text;
  }
  
  self.textField.attributedPlaceholder = self.attributedPlaceholder;
  self.textField.textAlignment = self.textAlignment;
  self.textField.typingAttributes = self.typingAttributes;
  
  self.textField.autocapitalizationType = self.autocapitalizationType;
  self.textField.autocorrectionType = self.autocorrectionType;
  self.textField.spellCheckingType = self.spellCheckingType;
  self.textField.keyboardType = self.keyboardType;
  self.textField.keyboardAppearance = self.keyboardAppearance;
  self.textField.returnKeyType = self.returnKeyType;
  self.textField.enablesReturnKeyAutomatically = self.enablesReturnKeyAutomatically;
  self.textField.secureTextEntry = self.isSecureTextEntry;
}

-(UITextField *)textField
{
  return (UITextField *) self.view;
}

// calculate the size of the text field by calculating the max height necessary to show either the text of the placeholder.
-(CGSize)calculateSizeThatFits:(CGSize)constrainedSize
{
  NSAttributedString *attributedText;
  NSAttributedString *attributedPlaceholder = self.attributedPlaceholder;
  
  if (self.attributedText != nil) {
    attributedText = self.attributedText;
  } else {
    attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:self.defaultTextAttributes];
  }
  
  // ensure there is some text to measure the height of the string for both text and placeholder
  if (attributedText.length == 0) {
    attributedText = [[NSAttributedString alloc] initWithString:@"Testing String" attributes:self.defaultTextAttributes];
  }
  
  if (attributedPlaceholder.length == 0) {
    NSDictionary *placeholderAttributes = self.defaultPlaceholderAttributes != nil ? self.defaultPlaceholderAttributes : self.defaultTextAttributes;
    attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Testing String" attributes:placeholderAttributes];
  }
  
  // text field text and placeholder is only ever on one line, so should be sized unconstrained.
  CGSize textConstrainSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
  
  // calculate the bounding boxes
  CGSize textSize = [attributedText boundingRectWithSize:textConstrainSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
  
  CGSize placeholderSize = [self.attributedPlaceholder boundingRectWithSize:textConstrainSize options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
  
  // text field should be high enough to hold either the placeholder or the tex with a default amount of padding
  CGFloat fittingHeight = MAX(textSize.height, placeholderSize.height) + 4;
  
  // node's size is the height of the text field and as wide as it is constrained to be.
  return CGSizeMake(constrainedSize.width, MIN(constrainedSize.height, fittingHeight));
}

-(void)layout
{
  ASDisplayNodeAssertMainThread();
  
  [super layout];
  self.textField.frame = self.bounds;
}

#pragma mark - First Responder Status

- (BOOL)isFirstResponder
{
  ASDN::MutexLocker l(_textFieldLock);
  return [self.textField isFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
  ASDN::MutexLocker l(_textFieldLock);
  return [self.textField canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
  ASDN::MutexLocker l(_textFieldLock);
  return [self.textField becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
  ASDN::MutexLocker l(_textFieldLock);
  return [self.textField canResignFirstResponder];
}

- (BOOL)resignFirstResponder
{
  ASDN::MutexLocker l(_textFieldLock);
  return [self.textField canResignFirstResponder];
}


#pragma mark - Setters

#pragma mark Text

-(void)setText:(NSString *)text
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (ASObjectIsEqual(_text, text)) {
    return;
  }
  
  _text = text;
  
  self.textField.text = text;
}

-(void)setAttributedText:(NSAttributedString *)attributedText
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (ASObjectIsEqual(_attributedText, attributedText)) {
    return;
  }
  
  _attributedText = attributedText;
  
  self.textField.attributedText = attributedText;
}

-(void)setDefaultTextAttributes:(NSDictionary<NSString *,id> *)defaultTextAttributes
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (ASObjectIsEqual(_defaultTextAttributes, defaultTextAttributes)) {
    return;
  }
  
  NSMutableDictionary *tempAttributes = [NSMutableDictionary dictionaryWithDictionary:_defaultTextAttributes];
  
  // override to set the current new values but retain the old ones where appropriate
  for (NSString *key in defaultTextAttributes.allKeys) {
    tempAttributes[key] = defaultTextAttributes[key];
  }
  
  _defaultTextAttributes = [NSDictionary dictionaryWithDictionary:tempAttributes];
  
  
  self.textField.defaultTextAttributes = defaultTextAttributes;
  
  // the font size could have changed, therefore invalidate current size
  [self invalidateCalculatedLayout];
}

#pragma mark Placeholder

-(NSString *)placeholder
{
  return self.attributedPlaceholder.string;
}

-(void)setPlaceholder:(NSString *)placeholder
{
  ASDN::MutexLocker l(_textFieldLock);
  
  NSDictionary *placeholderAttributes = self.defaultPlaceholderAttributes;
  
  if (placeholderAttributes == nil) {
    NSMutableDictionary *tempAttributes = [NSMutableDictionary dictionaryWithDictionary:self.defaultTextAttributes];
    
    UIColor *placeholderColor = tempAttributes[NSForegroundColorAttributeName];
    
    if (placeholderColor == nil) {
      placeholderColor = [UIColor blackColor];
    }
    
    tempAttributes[NSForegroundColorAttributeName] = [placeholderColor colorWithAlphaComponent:0.7];
    
    placeholderAttributes = tempAttributes;
  }
  
  NSAttributedString *attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:placeholderAttributes];
  self.attributedPlaceholder = attributedPlaceholder;
}

-(void)setAttributedPlaceholder:(NSAttributedString *)attributedPlaceholder
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (ASObjectIsEqual(_attributedPlaceholder, attributedPlaceholder)) {
    return;
  }
  
  _attributedPlaceholder = attributedPlaceholder;
  
  self.textField.attributedPlaceholder = attributedPlaceholder;
}

-(NSDictionary<NSString *,id> *)defaultPlaceholderAttributes
{
  if (_defaultPlaceholderAttributes != nil) {
    return _defaultPlaceholderAttributes;
  }
  
  NSMutableDictionary *tempAttributes = [NSMutableDictionary dictionaryWithDictionary:self.defaultTextAttributes];
  
  UIColor *placeholderColor = tempAttributes[NSForegroundColorAttributeName];
  
  if (placeholderColor == nil) {
    placeholderColor = [UIColor blackColor];
  }
  
  tempAttributes[NSForegroundColorAttributeName] = [placeholderColor colorWithAlphaComponent:0.7];
  
  return tempAttributes;
}

-(void)setDefaultPlaceholderAttributes:(NSDictionary<NSString *,id> *)defaultPlaceholderAttributes
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (ASObjectIsEqual(_defaultPlaceholderAttributes, defaultPlaceholderAttributes)) {
    return;
  }
  
  NSMutableDictionary *tempAttributes = [NSMutableDictionary dictionaryWithDictionary:_defaultPlaceholderAttributes];
  
  for (NSString *key in defaultPlaceholderAttributes.allKeys) {
    tempAttributes[key] = defaultPlaceholderAttributes[key];
  }
  
  _defaultPlaceholderAttributes = [NSDictionary dictionaryWithDictionary:tempAttributes];
  
  // reset the placeholder property - which will assign the new placeholder attributes to the current placeholder string
  NSString *currentPlaceholder = self.placeholder;
  self.placeholder = currentPlaceholder;
  
  // the font size could have changed, therefore invalidate current size
  [self invalidateCalculatedLayout];
}

#pragma mark Keyboard Properties

/*
 
 // property forwarding template
 
 ASDN::MutexLocker l(_textFieldLock);
 
 if (ASObjectIsEqual(_<#property#>, <#property#>)) {
 return;
 }
 
 _<#property#> = <#property#>;
 
 self.textField.<#property#> = <#property#>;
 
 */

-(void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType{
  
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_autocapitalizationType == autocapitalizationType) {
    return;
  }
  
  _autocapitalizationType = autocapitalizationType;
  
  self.textField.autocapitalizationType = autocapitalizationType;
}

-(void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_autocorrectionType == autocorrectionType) {
    return;
  }
  
  _autocorrectionType = autocorrectionType;
  
  self.textField.autocorrectionType = autocorrectionType;
}

-(void)setSpellCheckingType:(UITextSpellCheckingType)spellCheckingType
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_spellCheckingType == spellCheckingType) {
    return;
  }
  
  _spellCheckingType = spellCheckingType;
  
  self.textField.spellCheckingType = spellCheckingType;
}

-(void)setKeyboardType:(UIKeyboardType)keyboardType
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_keyboardType == keyboardType) {
    return;
  }
  
  _keyboardType = keyboardType;
  
  self.textField.keyboardType = keyboardType;
}

-(void)setKeyboardAppearance:(UIKeyboardAppearance)keyboardAppearance
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_keyboardAppearance == keyboardAppearance) {
    return;
  }
  
  _keyboardAppearance = keyboardAppearance;
  
  self.textField.keyboardAppearance = keyboardAppearance;
}

-(void)setReturnKeyType:(UIReturnKeyType)returnKeyType
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_returnKeyType == returnKeyType) {
    return;
  }
  
  _returnKeyType = returnKeyType;
  
  self.textField.returnKeyType = returnKeyType;
}

-(void)setEnablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_enablesReturnKeyAutomatically == enablesReturnKeyAutomatically) {
    return;
  }
  
  _enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
  
  self.textField.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically;
}

-(void)setSecureTextEntry:(BOOL)secureTextEntry
{
  ASDN::MutexLocker l(_textFieldLock);
  
  if (_secureTextEntry == secureTextEntry) {
    return;
  }
  
  _secureTextEntry = secureTextEntry;
  
  self.textField.secureTextEntry = secureTextEntry;
}

@end
