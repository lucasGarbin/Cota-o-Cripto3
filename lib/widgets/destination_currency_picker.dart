import 'package:flutter/material.dart';

class DestinationCurrencyPicker extends StatelessWidget {
  final String selectedCode;
  final List<String> codes;
  final String? Function(String code) nameForCode;
  final ValueChanged<String> onChanged;

  const DestinationCurrencyPicker({
    super.key,
    required this.selectedCode,
    required this.codes,
    required this.nameForCode,
    required this.onChanged,
  });

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return _CurrencySelectionDialog(
          selectedCode: selectedCode,
          codes: codes,
          nameForCode: nameForCode,
        );
      },
    );

    if (selected != null && selected != selectedCode) {
      onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = nameForCode(selectedCode);

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: codes.isEmpty ? null : () => _openPicker(context),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Moeda de destino',
          helperText: codes.isEmpty
              ? 'Aguardando cotações da API'
              : '${codes.length} moedas disponíveis',
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name == null || name.isEmpty
                    ? selectedCode
                    : '$selectedCode  •  $name',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Alterar',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrencySelectionDialog extends StatefulWidget {
  final String selectedCode;
  final List<String> codes;
  final String? Function(String code) nameForCode;

  const _CurrencySelectionDialog({
    required this.selectedCode,
    required this.codes,
    required this.nameForCode,
  });

  @override
  State<_CurrencySelectionDialog> createState() =>
      _CurrencySelectionDialogState();
}

class _CurrencySelectionDialogState
    extends State<_CurrencySelectionDialog> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    final filtered = widget.codes.where((code) {
      if (query.isEmpty) return true;
      final name = widget.nameForCode(code)?.toLowerCase() ?? '';
      return code.toLowerCase().contains(query) || name.contains(query);
    }).toList();

    return AlertDialog(
      title: const Text('Escolher moeda de destino'),
      content: SizedBox(
        width: 520,
        height: 560,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Pesquisar',
                hintText: 'BRL, USD, Bitcoin, Euro...',
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text('Nenhuma moeda encontrada.'),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: Theme.of(context).dividerColor),
                      itemBuilder: (context, index) {
                        final code = filtered[index];
                        final name = widget.nameForCode(code);
                        final selected = code == widget.selectedCode;

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          title: Text(
                            code,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: selected
                                  ? Theme.of(context).colorScheme.primary
                                  : null,
                            ),
                          ),
                          subtitle: name == null || name.isEmpty
                              ? null
                              : Text(name),
                          trailing: selected
                              ? Text(
                                  'Selecionada',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                )
                              : const Text('Escolher'),
                          onTap: () {
                            Navigator.of(context).pop(code);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
      ],
    );
  }
}
