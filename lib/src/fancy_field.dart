import 'package:flutter/material.dart';

class FancyField extends StatefulWidget {
  const FancyField(
      {super.key,
      required this.title,
      this.showTitle = true,
      this.fieldController,
      this.prefixIcon,
      this.hidePrefixIcon = false,
      this.suffixIcon,
      this.hideSuffixIcon = false,
      this.colorPrimary = Colors.black,
      this.colorSecundary = Colors.grey,
      this.maxLines = 1,
      this.isEnable = true,
      this.isReadOnly = false,
      this.isBorderless = false,
      this.borderWidth = 1.0,
      this.isOptionalField = false,
      this.validateField = true,
      this.forceHeight,
      this.borderRadiusField = 10.0,
      this.onChanged,
      this.keyboardType = TextInputType.text,
      this.errorMessage,
      this.errorMessageStyle,
      this.forceHeightErrorMessage,
      this.errorMessageBackground,
      this.errorMessageAlwaysShow = false,
      this.errorMessageInBottom = true,
      this.autoKeyboarCloser = true,
      this.cutomValidation});

  final String title;
  final bool showTitle;
  final TextEditingController? fieldController;
  final IconData? prefixIcon;
  final bool hidePrefixIcon;
  final IconData? suffixIcon;
  final bool hideSuffixIcon;
  final Color colorPrimary;
  final Color colorSecundary;
  final int maxLines;
  final bool isEnable;
  final bool isReadOnly;
  final bool isBorderless;
  final double borderWidth;
  final bool isOptionalField;
  final bool validateField;
  final double? forceHeight;
  final double borderRadiusField;
  final Function(String)? onChanged;
  final TextInputType keyboardType;
  final String? errorMessage;
  final TextStyle? errorMessageStyle;
  final double? forceHeightErrorMessage;
  final Color? errorMessageBackground;
  final bool errorMessageAlwaysShow;
  final bool errorMessageInBottom;
  final bool autoKeyboarCloser;
  final RegExp? cutomValidation;

  @override
  State<FancyField> createState() => _FancyFieldState();
}

class _FancyFieldState extends State<FancyField> {
  bool isPassword = false;
  bool hidePassword = true;
  bool hasError = false;
  final GlobalKey _key = GlobalKey();
  OverlayEntry? entry;
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _localControllerText = TextEditingController();

  @override
  void initState() {
    _focusNode.addListener(focusShow);
    //initilOverlay();
    super.initState();
  }

  initilOverlay() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      setState(() {
        entry = _getAlertMessage();
      });
    });
  }

  focusShow() {
    if (_focusNode.hasFocus) {
      if (entry != null && !entry!.mounted) {
        overlayShow();
      }
    } else {
      if (entry != null && entry!.mounted && !widget.errorMessageAlwaysShow) {
        overlayClose();
      }
      if (widget.autoKeyboarCloser) {
        FocusScope.of(context).unfocus();
      }
    }
  }

  overlayShow() {
    //update the overlay

    if (entry != null && entry!.mounted) {
      //entry!.markNeedsBuild();
    } else {
      setState(() {
        entry = _getAlertMessage();
      });

      Overlay.of(context).insert(entry!);
    }
  }

  overlayClose() {
    if (entry != null && entry!.mounted) {
      entry!.remove();
      setState(() {
        entry = null;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
          key: _key,
          constraints: BoxConstraints(
              maxHeight: widget.forceHeight ?? 50.0,
              minHeight: widget.forceHeight ?? 20),
          child: Stack(
            children: [
              Opacity(
                  opacity: 0.0,
                  child: TextFormField(
                    controller: widget.fieldController ?? _localControllerText,
                    validator: widget.validateField
                        ? (value) => validateSimple(value ?? "")
                        : null,
                  )),
              TextFormField(
                  onTapOutside: widget.autoKeyboarCloser
                      ? (event) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        }
                      : null,
                  focusNode: _focusNode,
                  controller: widget.fieldController ?? _localControllerText,
                  readOnly: widget.isReadOnly,
                  enabled: widget.isEnable,
                  onChanged: widget.onChanged ?? validateSimple,
                  keyboardType: widget.maxLines > 1
                      ? TextInputType.multiline
                      : widget.keyboardType,
                  maxLines: widget.maxLines < 1 ? 1 : widget.maxLines,
                  minLines: 1,
                  decoration: _getDecoration(),
                  obscureText: isPassword && hidePassword,
                  style: TextStyle(
                    color: widget.colorPrimary,
                    fontSize: fixTextSize(),
                  )),
            ],
          )),
    );
  }

  changeStatusError(bool value) {
    setState(() {
      hasError = value;
    });
  }

  validateOnChange(String value) {
    if (widget.cutomValidation != null) {
      //force this validation
      if (!widget.cutomValidation!.hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
      } else {
        overlayClose();
        changeStatusError(false);
      }
    } else {
      //basic validations
      if (widget.keyboardType == TextInputType.text ||
        widget.keyboardType == TextInputType.visiblePassword) {
        if (value.isEmpty) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
      } else if (widget.keyboardType == TextInputType.emailAddress) {
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
      } else if (widget.keyboardType == TextInputType.phone) {
        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
      } else if (widget.keyboardType == TextInputType.number) {
        if (!RegExp(r'^[0-9]+(?:\.[0-9]+)?$').hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
      }
    }
  }

  validateSimple(String value) {
    if (widget.cutomValidation != null) {
      //force this validation
      if (!widget.cutomValidation!.hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
      } else {
        overlayClose();
        changeStatusError(false);
      }
      return widget.cutomValidation!.hasMatch(value) ? null : "Error";
    } else {
      //basic validations
      if (widget.keyboardType == TextInputType.text ||
        widget.keyboardType == TextInputType.visiblePassword) {
        if (value.isEmpty) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
        return value.isNotEmpty ? null : widget.errorMessage ?? 'Error';
      } else if (widget.keyboardType == TextInputType.emailAddress) {
        if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
        return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
            .hasMatch(value)
          ? null
          : widget.errorMessage ?? 'Error';
      } else if (widget.keyboardType == TextInputType.phone) {
        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
        return RegExp(r'^\d{10}$').hasMatch(value)
          ? null
          : widget.errorMessage ?? 'Error';
      } else if (widget.keyboardType == TextInputType.number) {
        if (!RegExp(r'^[0-9]+(?:\.[0-9]+)?$').hasMatch(value)) {
        overlayShow();
        changeStatusError(true);
        } else {
        overlayClose();
        changeStatusError(false);
        }
        return RegExp(r'^[0-9]+(?:\.[0-9]+)?$').hasMatch(value)
          ? null
          : widget.errorMessage ?? 'Error';
      } else {
        return null;
      }
    }
  }

  fixHeightField() {}

  InputDecoration _getDecoration() => InputDecoration(
        counterText: '',
        //isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        filled: true,
        labelText: widget.showTitle ? widget.title : null,
        labelStyle: TextStyle(
          color: widget.colorPrimary,
        ),
        suffix: SizedBox(
            width: 0,
            height: widget.forceHeight ?? 0,
            child: const Opacity(
              opacity: 0.0,
              child: Text(""),
            )),
        //isDense: true,
        //isCollapsed: true,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : _getDefaultPrefixIcon(),
        suffixIcon: _getDefaultSufixIcon(),
        border: widget.isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.colorPrimary, width: widget.borderWidth),
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadiusField),
                ),
              ),
        enabledBorder: widget.isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.colorPrimary, width: widget.borderWidth),
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadiusField),
                ),
              ),
        focusedBorder: widget.isBorderless
            ? InputBorder.none
            : OutlineInputBorder(
                borderSide: BorderSide(
                    color: widget.colorPrimary,
                    width: (widget.borderWidth) * 2),
                borderRadius: BorderRadius.all(
                  Radius.circular(widget.borderRadiusField),
                )),
        // prefixIconColor: Colors.red.withOpacity(0.8)
      );

  Widget? _getDefaultPrefixIcon() {
    if (!widget.hidePrefixIcon) {
      if (widget.prefixIcon != null) {
        return Icon(widget.prefixIcon, color: widget.colorPrimary);
      } else {
        if (widget.keyboardType == TextInputType.emailAddress) {
          return Icon(Icons.email_rounded, color: widget.colorPrimary);
        } else if (widget.keyboardType == TextInputType.phone) {
          return Icon(Icons.phone_rounded, color: widget.colorPrimary);
        } else if (widget.keyboardType == TextInputType.number) {
          return Icon(Icons.numbers_rounded, color: widget.colorPrimary);
        } else if (widget.keyboardType == TextInputType.visiblePassword) {
          setState(() {
            isPassword = true;
          });
          return Icon(
            Icons.lock_rounded,
            color: widget.colorPrimary,
            size: fixIconSize(30),
          );
        } else {
          return Icon(Icons.text_fields_rounded,
              color: widget.colorPrimary, size: fixIconSize(30));
        }
      }
    }
    return null;
  }

  fixIconSize(double base) {
    double fixHeight = widget.forceHeight != null
        ? widget.forceHeight! > 35
            ? base
            : widget.forceHeight!
        : base;
    return fixHeight * 0.9;
  }

  fixTextSize() {
    double base = 30.0;
    double fixHeight = widget.forceHeight != null
        ? widget.forceHeight! > 35
            ? base
            : widget.forceHeight!
        : base;
    return fixHeight * 0.5;
  }

//TODO: ajustar tamaño de prefix icon, error icon  y texto asi como el tamaño del hide-show pass
  Widget? _getDefaultSufixIcon() {
    List<Widget> list = [];

    if (hasError) {
      list.add(
        Icon(
          Icons.error,
          color: Colors.red.withOpacity(0.8),
          size: fixIconSize(25),
        ),
      );
    }

    if (!widget.hideSuffixIcon) {
      if (widget.suffixIcon != null) {
        list.add(Icon(widget.suffixIcon, color: widget.colorPrimary));
        return _getBaseSufix(list);
      } else {
        if(widget.keyboardType ==TextInputType.visiblePassword){
            list.add(SizedBox(
              height: fixIconSize(30),
              child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Center(
                    child: Icon(
                      hidePassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: hidePassword
                          ? widget.colorPrimary.withOpacity(0.6)
                          : widget.colorPrimary,
                      size: fixIconSize(30),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      hidePassword = !hidePassword;
                    });
                  }),
            ));
            return _getBaseSufix(list);
        }
      }
    }

    return list.isNotEmpty ? _getBaseSufix(list) : null;
  }

  Widget _getBaseSufix(List<Widget> list) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: list,
      ),
    );
  }

  OverlayEntry _getAlertMessage() {
    double width = getWidgetSize(_key).width;
    double height = getWidgetSize(_key).height;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(
              0.0,
              widget.errorMessageInBottom
                  ? (height + 3)
                  : (-(widget.forceHeightErrorMessage ?? 40.0) - 5)),
          child: Material(
            color: Colors.transparent,
            //elevation: 1.0,
            child: Container(
              height: widget.forceHeightErrorMessage ?? 40.0,
              width: width,
              padding: const EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                color: widget.errorMessageBackground ??
                    Colors.orange.withOpacity(0.7),
                borderRadius: BorderRadius.circular(widget.borderRadiusField),
              ),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.errorMessage ?? 'Error',
                    style: widget.errorMessageStyle ??
                        const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

//Get the size of the widget
Size getWidgetSize(key) {
  RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
  return renderBox.size;
}
