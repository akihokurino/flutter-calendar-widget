import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextFieldView extends StatefulWidget {
  final bool isFocus;
  final ValueChanged<String>? onChange;
  final ValueChanged<String>? onSubmit;
  final String label;
  final String placeholder;
  final String value;
  final TextInputType inputType;
  final List<TextInputFormatter> formaters;

  TextFieldView(
      {this.isFocus = false,
      this.onChange,
      this.onSubmit,
      this.label = "",
      this.placeholder = "",
      this.value = "",
      this.inputType = TextInputType.text,
      this.formaters = const []});

  @override
  State<StatefulWidget> createState() => _TextFieldViewState();
}

class _TextFieldViewState extends State<TextFieldView> {
  late final TextEditingController _controller;
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(text: widget.value);

    _controller.addListener(() {
      final val = _controller.text;

      if (widget.onChange != null) {
        widget.onChange!(val);
      }
    });

    if (widget.isFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.zero,
      height: widget.label.isNotEmpty ? 100 : 60,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.label.isNotEmpty
              ? Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Text(widget.label, style: ThemeData.dark().textTheme.caption),
                )
              : Container(),
          Stack(
            children: [
              TextField(
                inputFormatters: widget.formaters,
                focusNode: _focusNode,
                onSubmitted: widget.onSubmit,
                controller: _controller,
                keyboardType: widget.inputType,
                decoration: InputDecoration(
                    hintText: widget.placeholder,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ThemeData.dark().dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: ThemeData.dark().dividerColor,
                      ),
                    )),
              ),
            ],
          )
        ],
      ),
    );
  }
}
