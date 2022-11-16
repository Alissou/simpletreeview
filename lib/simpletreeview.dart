library simpletreeview;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class TreeView extends InheritedWidget {
  final List<Object>? children;
  final Widget Function(Object)? getWidget;
  final Function(Object?)? onSelect;

  TreeView({
    Key? key,
    this.getWidget,
    required List<Object>? children,
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
  final List<Object>? children;
  final Widget Function(Object)? getWidget;
  final Function(Object?)? onSelect;

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
  final Future<List<Object>>? children;
  final VoidCallback? onTap;
  Object? data;
  Widget Function(Object)? getWidget;
  Function(Object?)? onSelect;

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

  List<Widget> getChildren(List<Object> data) {
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
    Future<List<Object>>? children,
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
                ? FutureBuilder<List<Object>>(
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
