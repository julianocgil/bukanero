import 'package:flutter/material.dart';

import '../data/groups_db.dart';
import '../domain/section.dart';
import '../l10n/tr.dart';

/// Lista os grupos juntados só por nome e imagem (os que podem errar),
/// para conferir rápido numa lista nova e separar o que estiver estranho.
Future<void> showReviewGroups(
  BuildContext context, {
  required List<GroupReview> groups,
  required bool Function(String key) isSeparated,
  required void Function(String key, {required bool separated}) onSet,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext ctx) =>
        _ReviewDialog(groups: groups, isSeparated: isSeparated, onSet: onSet),
  );
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({
    required this.groups,
    required this.isSeparated,
    required this.onSet,
  });

  final List<GroupReview> groups;
  final bool Function(String key) isSeparated;
  final void Function(String key, {required bool separated}) onSet;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final ThemeData t = Theme.of(context);
    final String q = normalize(_query.trim());
    final List<GroupReview> list = q.isEmpty
        ? widget.groups
        : <GroupReview>[
            for (final GroupReview g in widget.groups)
              if (normalize(g.name).contains(q)) g,
          ];
    final Size screen = MediaQuery.sizeOf(context);
    return AlertDialog(
      title: Text(tr.reviewGroups),
      content: SizedBox(
        width: 640,
        height: screen.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              tr.reviewIntro(widget.groups.length),
              style: t.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: tr.searchGroup,
                isDense: true,
              ),
              onChanged: (String v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: list.isEmpty
                  ? Center(child: Text(tr.nothingToReview))
                  : ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (BuildContext context, int i) =>
                          const Divider(height: 1),
                      itemBuilder: (BuildContext context, int i) {
                        final GroupReview g = list[i];
                        final bool apart = widget.isSeparated(g.key);
                        final List<String> shown = g.labels.take(6).toList();
                        return ListTile(
                          dense: true,
                          title: Text(
                            g.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: apart
                                ? TextStyle(color: t.disabledColor)
                                : null,
                          ),
                          subtitle: Text(
                            '${shown.join(' · ')}'
                            '${g.labels.length > 6 ? ' · +${g.labels.length - 6}' : ''}'
                            '\n${reasonsLabel(g.reasons)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: TextButton.icon(
                            icon: Icon(
                              apart ? Icons.merge_type : Icons.call_split,
                            ),
                            label: Text(apart ? tr.regroup : tr.separate),
                            onPressed: () => setState(
                              () => widget.onSet(g.key, separated: !apart),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        FilledButton(
          onPressed: () => Navigator.pop(context),
          child: Text(tr.close),
        ),
      ],
    );
  }
}
