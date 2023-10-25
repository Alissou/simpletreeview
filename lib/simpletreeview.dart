library simpletreeview;

import 'package:flutter/material.dart';

class TreeView extends InheritedWidget {
  final List<dynamic>? children;
  final Widget Function(dynamic)? getWidget;
  final Function(dynamic?)? onSelect;

  TreeView({
    Key? key,
    this.getWidget,
    required List<dynamic>? children,
    this.onSelect,
  })  : this.children = children,
        super(
          key: key,
          child: _TreeViewData(
            children: children,
            getWidget: getWidget,
            onSelect: onSelect,
          ),
        );

  static TreeView? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TreeView>();
  }

  @override
  bool updateShouldNotify(TreeView oldWidget) {
    if (oldWidget.children == this.children) {
      return false;
    }
    return true;
  }
}

class _TreeViewData extends StatelessWidget {
  final List<dynamic>? children;
  final Widget Function(dynamic)? getWidget;
  final Function(dynamic?)? onSelect;

  const _TreeViewData({this.children, this.getWidget, this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: children!.length,
      itemBuilder: (context, index) {
        var data = children!.elementAt(index);
        TreeViewChild? tv = getWidget!(data) as TreeViewChild;
        tv.data = data;
        tv.onSelect = onSelect;
        tv.getWidget = getWidget;
        return tv;
      },
    );
  }
}

class TreeViewChild extends StatefulWidget {
  final Widget? parent;
  final Future<List<dynamic>>? children;
  final VoidCallback? onTap;
  dynamic data;
  Widget Function(dynamic)? getWidget;
  Function(dynamic)? onSelect;

  TreeViewChild(
      {required this.parent,
      required this.children,
      this.onTap,
      Key? key,
      this.data,
      this.getWidget,
      this.onSelect})
      : super(key: key) {
    assert(parent != null);
    assert(children != null);
  }

  List<Widget> getChildren(List<dynamic> data) {
    List<Widget> ret = [];
    for (var e in data) {
      var w = getWidget!(e);
      TreeViewChild? tv = w as TreeViewChild;
      tv.onSelect = onSelect;
      tv.getWidget = getWidget;
      tv.data = e;
      ret.add(w);
    }
    return ret;
  }

  @override
  TreeViewChildState createState() => TreeViewChildState();

  TreeViewChild copyWith(
    TreeViewChild source, {
    Widget? parent,
    Future<List<dynamic>>? children,
    VoidCallback? onTap,
  }) {
    return TreeViewChild(
      parent: parent ?? source.parent,
      children: children ?? source.children,
      onTap: onTap ?? source.onTap,
      data: source.data,
      getWidget: source.getWidget,
      onSelect: source.onSelect,
    );
  }
}

class TreeViewChildState extends State<TreeViewChild> {
  bool? isExpanded;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            child: widget.parent,
            onTap: () => {
              setState(() {
                this.isExpanded = this.isExpanded != true;
                widget.onSelect!(widget.data);
              })
            },
          ),
          AnimatedContainer(
            duration: Duration(milliseconds: 500),
            child: isExpanded == true
                ? FutureBuilder<List<dynamic>>(
                    future: widget.children,
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || snapshot.data!.length == 0) {
                        return Offstage();
                      }
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: widget.getChildren(snapshot.data!),
                      );
                    })
                : Offstage(),
          ),
        ],
      ),
    );
  }
}
