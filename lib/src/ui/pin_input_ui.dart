import 'package:flutter/material.dart';

class PinInputUI extends StatefulWidget {
  final bool randomize;
  final String title;
  final int pinLength;
  final String subHeading;
  final bool showIndicatorPlaceholder;
  final double indicatorPadding;

  PinInputUI(
      {@required this.randomize,
      @required this.title,
      @required this.pinLength,
      @required this.subHeading,
      @required this.showIndicatorPlaceholder,
      @required this.indicatorPadding});

  @override
  State<StatefulWidget> createState() => new _PinInputUIState();
}

class _PinInputUIState extends State<PinInputUI> {
  var _scaffoldKey = new GlobalKey<ScaffoldState>();
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
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        backgroundColor: Colors.lightBlue[900],
        title: new Text(widget.title),
      ),
      body: new Container(
        child: new Stack(
          children: <Widget>[
            new Positioned(
                top: 20.0,
                left: 10.0,
                right: 10.0,
                height: MediaQuery.of(context).size.height / 3.0,
                child: new Container(
                  alignment: Alignment.bottomCenter,
                  child: new Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Text(
                        widget.subHeading,
                        textAlign: TextAlign.center,
                        style: new TextStyle(fontSize: 20.0),
                      ),
                      new SizedBox(height: 80.0),
                      new Container(
                          height: 20.0,
                          alignment: Alignment.center,
                          child: _getIndicators()),
                      new SizedBox(
                        height: 20.0,
                      ),
                    ],
                  ),
                )),
            new Positioned(
              bottom: 5.0,
              left: 20.0,
              right: 20.0,
              height: MediaQuery.of(context).size.height / 2.0,
              child: new Container(
                child: new GridView.count(
                  crossAxisCount: 3,
                  childAspectRatio: 1.5,
                  physics: new NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(4.0),
                  children: _getButtonsChildren(),
                ),
              ),
            )
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
        widgets.add(new IconButton(
            icon: new Icon(Icons.backspace),
            onPressed: _selectedPins.isNotEmpty ? _clearPins : null));
      } else if (number == 200) {
        widgets.add(new IconButton(
            onPressed: _selectedPins.length >= 4 ? _processSubmit : null,
            icon: new Text(
              'DONE',
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
              size: 17.0,
              color: Colors.grey,
            ),
          );
        }).toList(),
      );
    }
  }
}
