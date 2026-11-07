/// Formas de ordenar os itens de uma lista.
enum SortMode {
  listOrder('Ordem da lista', false),
  listOrderReverse('Ordem da lista (invertida)', false),
  nameAsc('A → Z', false),
  nameDesc('Z → A', false),
  recent('Adicionados recentemente', true),
  rating('Melhor nota', true),
  year('Ano (mais novo)', true);

  const SortMode(this.label, this.needsMeta);

  final String label;

  /// True se depende de nota/data vindas da API do servidor.
  final bool needsMeta;
}
