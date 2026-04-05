import 'package:bdp/database/papeleriadb.dart';
import 'package:bdp/models/categoria_model.dart';
import 'package:bdp/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

class CategoriasScreen extends StatefulWidget {
  const CategoriasScreen({super.key});
  @override
  State<CategoriasScreen> createState() => _CategoriasScreenState();
}

class _CategoriasScreenState extends State<CategoriasScreen>
    with AutomaticKeepAliveClientMixin {
  final PapeleriaDB _db = PapeleriaDB();
  List<Categoria> _categorias = [];

  @override
  bool get wantKeepAlive => true;

  static const Map<String, IconData> _iconMap = {
    'candy': Icons.cake_rounded,
    'print': Icons.print_rounded,
    'description': Icons.description_rounded,
    'cut': Icons.content_cut_rounded,
    'toys': Icons.toys_rounded,
    'category': Icons.category_rounded,
    'shopping': Icons.shopping_bag_rounded,
    'school': Icons.school_rounded,
    'brush': Icons.brush_rounded,
    'star': Icons.star_rounded,
  };

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final cats = await _db.getCategorias();
    setState(() => _categorias = cats);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                const Text('Categorías',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark)),
                const Spacer(),
                TextButton.icon(
                  onPressed: _mostrarFormCategoria,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Nueva'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: AnimationLimiter(
            child: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => AnimationConfiguration.staggeredGrid(
                  position: i,
                  duration: const Duration(milliseconds: 375),
                  columnCount: 2,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: _CategoriaCard(
                        categoria: _categorias[i],
                        iconData: _iconMap[_categorias[i].icono] ??
                            Icons.category_rounded,
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/productos',
                          arguments: {
                            'idCategoria': _categorias[i].idCategoria,
                            'nombreCategoria': _categorias[i].nombre,
                          },
                        ).then((_) => _cargar()),
                        onEdit: () =>
                            _mostrarFormCategoria(cat: _categorias[i]),
                        onDelete: () => _confirmarEliminar(_categorias[i]),
                      ),
                    ),
                  ),
                ),
                childCount: _categorias.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  void _mostrarFormCategoria({Categoria? cat}) {
    final conNombre = TextEditingController(text: cat?.nombre ?? '');
    String selectedIcon = cat?.icono ?? 'category';
    String selectedColor = cat?.color ?? '#FF9800';

    final iconOpts = _iconMap.entries.toList();
    final colorOpts = [
      '#FF4081', '#2196F3', '#FF9800', '#9C27B0', '#4CAF50',
      '#F44336', '#00BCD4', '#FFC107', '#607D8B', '#795548',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setStateDialog) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            cat == null ? 'Nueva categoría' : 'Editar categoría',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: conNombre,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.label_rounded),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Icono',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMid,
                        fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: iconOpts.map((e) {
                    final sel = selectedIcon == e.key;
                    return InkWell(
                      onTap: () =>
                          setStateDialog(() => selectedIcon = e.key),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.primary.withOpacity(0.15)
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: sel
                              ? Border.all(color: AppTheme.primary, width: 2)
                              : null,
                        ),
                        child: Icon(e.value,
                            size: 24,
                            color: sel ? AppTheme.primary : AppTheme.textMid),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text('Color',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textMid,
                        fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colorOpts.map((c) {
                    final sel = selectedColor == c;
                    return InkWell(
                      onTap: () =>
                          setStateDialog(() => selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hexToColor(c),
                          shape: BoxShape.circle,
                          border: sel
                              ? Border.all(color: Colors.black54, width: 3)
                              : null,
                        ),
                        child: sel
                            ? const Icon(Icons.check, color: Colors.white, size: 18)
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                if (conNombre.text.trim().isEmpty) return;
                final nueva = Categoria(
                  idCategoria: cat?.idCategoria,
                  nombre: conNombre.text.trim(),
                  icono: selectedIcon,
                  color: selectedColor,
                );
                if (cat == null) {
                  await _db.insertCategoria(nueva);
                } else {
                  await _db.updateCategoria(nueva);
                }
                if (mounted) {
                  Navigator.pop(ctx);
                  _cargar();
                }
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(Categoria cat) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
            '¿Deseas eliminar "${cat.nombre}"?\nNo es posible si tiene productos.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.statusCancelada),
            onPressed: () async {
              try {
                await _db.deleteCategoria(cat.idCategoria!);
                if (mounted) { Navigator.pop(ctx); _cargar(); }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('No se puede eliminar: tiene productos'),
                    backgroundColor: AppTheme.statusCancelada,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ));
                }
              }
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

// ─── Card widget ────────────────────────────────────────────────────────────

class _CategoriaCard extends StatelessWidget {
  final Categoria categoria;
  final IconData iconData;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoriaCard({
    required this.categoria,
    required this.iconData,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = hexToColor(categoria.color);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                  ),
                ),
              ),
            ),
            Positioned(
              right: -20, bottom: -20,
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(iconData, color: color, size: 24),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      iconSize: 18,
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.more_vert_rounded,
                          size: 18, color: AppTheme.textMid),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit',   child: Text('Editar')),
                        PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                      ],
                      onSelected: (v) {
                        if (v == 'edit')   onEdit();
                        if (v == 'delete') onDelete();
                      },
                    ),
                  ]),
                  const Spacer(),
                  Text(
                    categoria.nombre,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: color.darken(0.3),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.arrow_forward_rounded,
                        size: 14, color: AppTheme.textMid),
                    const SizedBox(width: 4),
                    const Text('Ver productos',
                        style: TextStyle(fontSize: 11, color: AppTheme.textMid)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
