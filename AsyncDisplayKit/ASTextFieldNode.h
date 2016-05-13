//
//  ASTextFieldNode.h
//  AsyncDisplayKit
//
//  Created by Josh Campion on 13/05/2016.
//  Copyright © 2016 Facebook. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 @abstract Implements a node that supports editing a single line of text.
 @discussion Does not support layer backing.
 */
@interface ASTextFieldNode : ASDisplayNode <UITextInputTraits>

- (instancetype)init;

/**
 @abstract Access to underlying UITextField for more configuration options.
 @warning This property should only be used on the main thread and should not be accessed before the text field node's view is created.
 */
@property (nonatomic, readonly, strong) UITextField *textField;

#pragma mark - Accessing the Text Attributes

/**
 @abstract The text displayed by the receiver.
 @discussion When the placeholder is displayed, this value is nil. Otherwise, this value is the attributed text the user has entered. This value can be modified regardless of whether the receiver is the first responder (and thus, editing) or not. Changing this value from nil to non-nil will result in the placeholder being hidden, and the new value being displayed.
 */
@property (nonatomic, readwrite, copy, nullable) NSString *text;

/**
 @abstract The styled text displayed by the receiver.
 @discussion When the placeholder is displayed (as indicated by -isDisplayingPlaceholder), this value is nil. Otherwise, this value is the attributed text the user has entered. This value can be modified regardless of whether the receiver is the first responder (and thus, editing) or not. Changing this value from nil to non-nil will result in the placeholder being hidden, and the new value being displayed.
 */
@property (nonatomic, readwrite, copy, nullable) NSAttributedString *attributedText;

/**
 @abstract The default attributes to apply to the text.
 @discussion By default, this property returns a dictionary of text attributes with default values.
 
 Setting this property applies the specified attributes to the entire text of the text field. Unset attributes maintain their default values.
 
 Getting this property returns the previously set attributes, which may have been modified by setting properties such as font and textColor.
 */
@property(nonatomic, copy) NSDictionary <NSString *,id> *defaultTextAttributes;

/**
 @abstract The string that is displayed when there is no other text in the text field.
 @discussion This value is nil by default. The placeholder string is drawn using a 70% opacity color of the defaultTextAttributes if defaultPlaceholderAttributes is nil.
 */
@property (nonatomic, readwrite, copy, nullable) NSString *placeholder;

/**
 @abstract The styled placeholder text displayed by the text node while no text is entered
 @discussion The placeholder is displayed when the user has not entered any text and the keyboard is not visible.
 */
@property (nonatomic, readwrite, strong, nullable) NSAttributedString *attributedPlaceholder;


/**
 @abstract The default attributes to apply to the placeholder.
 @discussion By default, this property returns a dictionary of placeholder attributes with default values.
 
 Setting this property applies the specified attributes to the entire placeholder of the text field. Unset attributes maintain their default values.
 
 Getting this property returns the default values if they have not been set. Default values are defaultTextAttributes, with NSForegroundColorAttributeName 70% opacity of that in defaultTextAttributes.
 */
@property(nonatomic, copy) NSDictionary <NSString *,id> *defaultPlaceholderAttributes;

//! @abstract The attributes to apply to new text being entered by the user.
@property (nonatomic, readwrite, strong, nullable) NSDictionary<NSString *, id> *typingAttributes;

//! @abstract The technique to use for aligning the text.
@property (nonatomic, readwrite, assign) NSTextAlignment textAlignment;

#pragma mark - UITextInputTraits properties

/**
 @abstract The autocapitalizationType of the textField. This value defaults to UITextAutocapitalizationTypeSentences.
 */
@property(nonatomic) UITextAutocapitalizationType autocapitalizationType;

/**
 @abstract The autocorrectionType of the textField. This value defaults to UITextAutocorrectionTypeDefault.
 */
@property(nonatomic) UITextAutocorrectionType autocorrectionType;

/**
 @abstract The spellCheckingType of the textField. This value defaults to UITextSpellCheckingTypeDefault.
 */
@property(nonatomic) UITextSpellCheckingType spellCheckingType;

/**
 @abstract The keyboardType of the textField. This value defaults to UIKeyboardTypeDefault.
 */
@property(nonatomic) UIKeyboardType keyboardType;

/**
 @abstract The keyboardAppearance of the textField. This value defaults to UIKeyboardAppearanceDefault.
 */
@property(nonatomic) UIKeyboardAppearance keyboardAppearance;

/**
 @abstract The returnKeyType of the textField. This value defaults to UIReturnKeyDefault.
 */
@property (nonatomic, readwrite) UIReturnKeyType returnKeyType;

/**
 @abstract The enablesReturnKeyAutomatically value for the textField. This value defaults to NO.
 @discussion When YES, will automatically disable return key when text widget has zero-length contents, and will automatically enable when text widget has non-zero-length contents.
 */
@property(nonatomic) BOOL enablesReturnKeyAutomatically;

/**
 @abstract The secureTextEntry of the textField. This value defaults to NO.
 */
@property(nonatomic,getter=isSecureTextEntry) BOOL secureTextEntry;

#pragma mark - Managing First Responder Status

/**
 @abstract Indicates whether the receiver's text view is the first responder, and thus has the keyboard visible and is prepared for editing by the user.
 @result YES if the receiver's text view is the first-responder; NO otherwise.
 */
- (BOOL)isFirstResponder;

- (BOOL)canBecomeFirstResponder;

//! @abstract Makes the receiver's text view the first responder.
- (BOOL)becomeFirstResponder;

- (BOOL)canResignFirstResponder;

//! @abstract Resigns the receiver's text view from first-responder status, if it has it.
- (BOOL)resignFirstResponder;

@end

NS_ASSUME_NONNULL_END