import 'package:flutter/material.dart';

class PinInputUI extends StatefulWidget {
  final bool randomize;
  final int pinLength;
  final bool showIndicatorPlaceholder;
  final double indicatorPadding;

  PinInputUI(
      {@required this.randomize,
        @required this.pinLength,
        @required this.showIndicatorPlaceholder,
        @required this.indicatorPadding});

  @override
  State<StatefulWidget> createState() => new _PinInputUIState();
}

class _PinInputUIState extends State<PinInputUI> {
  var _numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0];
  List<String> _selectedPins = [];

  @override
  void initState() {
    super.initState();
    if (widget.randomize) {
      _numbers.shuffle();
    }
    // 100 is clear button
    // 200 is submit button
    _numbers.insert(9, 100); // Replaces index 9 with clear button
    _numbers.add(200);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> buttons = _getButtonsChildren();
    return new Container(
      child: SingleChildScrollView(
        child: new ListBody(
          children: <Widget>[
            new SizedBox(
              height: 10.0,
            ),
            new Container(
                height: 20.0,
                alignment: Alignment.center,
                child: _getIndicators()),
            new SizedBox(
              height: 20.0,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons.sublist(0, 3),
            ),
            new SizedBox(
              height: 20.0,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons.sublist(3, 6),
            ),
            new SizedBox(
              height: 20.0,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: buttons.sublist(6, 9),
            ),
            new SizedBox(
              height: 20.0,
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Expanded(child: buttons[9]),
                new Expanded(child: buttons[10]),
                new Expanded(child: buttons[11])
              ],
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getButtonsChildren() {
    List<Widget> widgets = [];
    for (var i = 0; i < _numbers.length; i++) {
      var number = _numbers[i];

      if (number == 100) {
        widgets.add(new Container(
          alignment: Alignment.centerLeft,
          child: new IconButton(
              icon: new Icon(Icons.backspace),
              onPressed: _selectedPins.isNotEmpty ? _clearPins : null),
        ));
      } else if (number == 200) {
        widgets.add(new IconButton(
            onPressed: _selectedPins.length >= 4 ? _processSubmit : null,
            icon: new Text(
              'DONE',
              textAlign: TextAlign.end,
              softWrap: false,
              style: new TextStyle(
                  fontWeight: FontWeight.bold,
                  color:
                  _selectedPins.length >= 4 ? Colors.black : Colors.grey),
            )));
      } else {
        widgets.add(getNumberWidget(number));
      }
    }
    return widgets;
  }

  Widget getNumberWidget(int number) {
    return new IconButton(
        onPressed: _selectedPins.length < widget.pinLength
            ? () => _handleNumberPress(number)
            : null,
        icon: new Text(
          number.toString(),
          style: new TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: _selectedPins.length < widget.pinLength
                  ? Colors.black
                  : Colors.grey),
        ));
  }

  void _handleNumberPress(int number) {
    print('Pressed $number');
    setState(() {
      _selectedPins.add(number.toString());
    });
  }

  void _clearPins() {
    if (_selectedPins.isNotEmpty) {
      setState(() {
        _selectedPins.removeLast();
      });
    }
  }

  void _processSubmit() {
    var buffer = new StringBuffer();
    for (var i = 0; i < _selectedPins.length; i++) {
      buffer.write(_selectedPins[i]);
    }

    Navigator.pop(context, buffer.toString());
  }

  Widget _getIndicators() {
    if (widget.showIndicatorPlaceholder) {
      var placeHoldersLength = widget.pinLength - _selectedPins.length;
      List<Widget> placeHolders = [];
      for (var i = 0; i < placeHoldersLength; i++) {
        placeHolders.add(Padding(
          padding:
          new EdgeInsets.symmetric(horizontal: widget.indicatorPadding),
          child: new Icon(
            Icons.panorama_fish_eye,
            size: 17.0,
            color: Colors.grey,
          ),
        ));
      }

      List<Widget> indicators = _selectedPins.map((s) {
        return Padding(
          padding:
          new EdgeInsets.symmetric(horizontal: widget.indicatorPadding),
          child: new Icon(
            Icons.brightness_1,
            size: 17.0,
            color: Colors.grey,
          ),
        );
      }).toList();

      List<Widget> widgets = [];
      widgets.addAll(indicators);
      widgets.addAll(placeHolders);

      return new Row(
          mainAxisAlignment: MainAxisAlignment.center, children: widgets);
    } else {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _selectedPins.map((s) {
          return new Padding(
            padding:
            new EdgeInsets.symmetric(horizontal: widget.indicatorPadding),
            child: new Icon(
              Icons.brightness_1,
              size: 10.0,
              color: Colors.grey,
            ),
          );
        }).toList(),
      );
    }
  }
}
