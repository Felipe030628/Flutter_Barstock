class Categoria {
  final int id;
  final String nombre;

  Categoria({
    required this.id,
    required this.nombre,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: int.tryParse('${json['id'] ?? 0}') ?? 0,
      nombre: '${json['nombre'] ?? ''}',
    );
  }
}
