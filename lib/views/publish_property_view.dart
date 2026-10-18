import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/property.dart';
import '../models/user.dart';
import '../theme/app_colors.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/publish_property_viewmodel.dart';

class PublishPropertyView extends StatelessWidget {
  const PublishPropertyView({super.key});

  @override
  Widget build(BuildContext context) {
    // Si el ViewModel ya está en el árbol (por ejemplo en tests), se reutiliza;
    // de lo contrario, se provee automáticamente.
    try {
      Provider.of<PublishPropertyViewModel>(context, listen: false);
      return const _PublishPropertyFormWrapper();
    } catch (_) {
      return ChangeNotifierProvider(
        create: (_) => PublishPropertyViewModel(),
        child: const _PublishPropertyFormWrapper(),
      );
    }
  }
}

class _PublishPropertyFormWrapper extends StatelessWidget {
  const _PublishPropertyFormWrapper();

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user;

    // Validación de rol: sólo accesible para arrendador
    if (user == null || user.role != AppUser.roleArrendador) {
      return Scaffold(
        backgroundColor: AppColors.arena,
        appBar: AppBar(
          backgroundColor: AppColors.arena,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.texto),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: const Text(
            'Acceso restringido',
            style: TextStyle(
              color: AppColors.texto,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.terracota.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_person_rounded,
                    size: 64,
                    color: AppColors.terracota,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Solo para arrendadores',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texto,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Esta pantalla es de uso exclusivo para usuarios con rol de arrendador. Si consideras que esto es un error, por favor verifica tu cuenta.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.texto,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 28),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Volver al inicio'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.terracota,
                    foregroundColor: AppColors.blanco,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return const _PublishPropertyFormView();
  }
}

class _PublishPropertyFormView extends StatefulWidget {
  const _PublishPropertyFormView();

  @override
  State<_PublishPropertyFormView> createState() =>
      _PublishPropertyFormViewState();
}

class _PublishPropertyFormViewState extends State<_PublishPropertyFormView> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _distanceController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoUrlController = TextEditingController();

  String _selectedType = Property.typeHabitacion;
  final Set<String> _selectedServices = <String>{};

  // Servicios disponibles
  static const List<Map<String, dynamic>> _availableServices = [
    {'id': 'agua', 'label': 'Agua', 'icon': Icons.water_drop_outlined},
    {'id': 'internet', 'label': 'Internet', 'icon': Icons.wifi_rounded},
    {'id': 'amueblado', 'label': 'Amueblado', 'icon': Icons.chair_outlined},
    {'id': 'luz', 'label': 'Luz', 'icon': Icons.lightbulb_outline_rounded},
    {
      'id': 'lavandería',
      'label': 'Lavandería',
      'icon': Icons.local_laundry_service_outlined
    },
  ];

  static const List<Map<String, String>> _propertyTypes = [
    {'id': Property.typeHabitacion, 'label': 'Habitación'},
    {'id': Property.typeDepartamento, 'label': 'Departamento'},
    {'id': Property.typeEstudio, 'label': 'Estudio'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _distanceController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  void _addPhoto(PublishPropertyViewModel vm) {
    final text = _photoUrlController.text.trim();
    if (text.isEmpty) return;
    final success = vm.addPhotoUrl(text);
    if (success) {
      _photoUrlController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  Future<void> _submit(
      BuildContext context, PublishPropertyViewModel vm, AppUser user) async {
    // Quita foco del teclado
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price =
        double.tryParse(_priceController.text.trim().replaceAll(',', '.'));
    final distance = int.tryParse(_distanceController.text.trim()) ?? 0;

    final success = await vm.publish(
      title: _titleController.text.trim(),
      price: price,
      distanceMinutes: distance,
      type: _selectedType,
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      services: _selectedServices.toList(),
      ownerId: user.id,
    );

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AppColors.blanco),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '¡Propiedad publicada con éxito!',
                  style: TextStyle(
                    color: AppColors.blanco,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.salvia,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      Navigator.of(context).pop();
    } else if (vm.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            vm.errorMessage!,
            style: const TextStyle(color: AppColors.blanco),
          ),
          backgroundColor: AppColors.errorTexto,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PublishPropertyViewModel>();
    final authVM = context.watch<AuthViewModel>();
    final user = authVM.user!;

    return Scaffold(
      backgroundColor: AppColors.arena,
      appBar: AppBar(
        backgroundColor: AppColors.arena,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.texto),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Publicar propiedad',
          style: TextStyle(
            color: AppColors.texto,
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Mensaje de error general si existe
                if (vm.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.errorFondo,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.errorTexto.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.errorTexto,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            vm.errorMessage!,
                            style: const TextStyle(
                              color: AppColors.errorTexto,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Sección 1: Datos principales
                _buildSectionCard(
                  title: 'Información general',
                  icon: Icons.info_outline_rounded,
                  children: [
                    // Título
                    TextFormField(
                      controller: _titleController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        labelText: 'Título de la propiedad *',
                        hintText: 'Ej. Habitación luminosa cerca del campus',
                        prefixIcon: Icons.home_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa un título para la propiedad';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de propiedad
                    const Text(
                      'Tipo de vivienda *',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _propertyTypes.map((type) {
                        final isSelected = _selectedType == type['id'];
                        return ChoiceChip(
                          label: Text(type['label']!),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedType = type['id']!;
                              });
                            }
                          },
                          selectedColor: AppColors.terracota,
                          backgroundColor: AppColors.blanco,
                          labelStyle: TextStyle(
                            color:
                                isSelected ? AppColors.blanco : AppColors.texto,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.terracota
                                : AppColors.salvia,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Precio al mes y Minutos a pie (en fila)
                    Row(
                      children: [
                        // Precio
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              labelText: 'Precio al mes *',
                              hintText: 'Ej. 3500',
                              prefixIcon: Icons.attach_money_rounded,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Ingresa el precio';
                              }
                              final numVal = double.tryParse(
                                value.trim().replaceAll(',', '.'),
                              );
                              if (numVal == null || numVal <= 0) {
                                return 'Precio mayor a 0';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Minutos a pie
                        Expanded(
                          child: TextFormField(
                            controller: _distanceController,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.next,
                            decoration: _inputDecoration(
                              labelText: 'Minutos a pie',
                              hintText: 'Ej. 10',
                              prefixIcon: Icons.directions_walk_rounded,
                              suffixText: 'min',
                            ),
                            validator: (value) {
                              if (value != null && value.trim().isNotEmpty) {
                                final val = int.tryParse(value.trim());
                                if (val == null || val < 0) {
                                  return 'Minutos válidos';
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sección 2: Ubicación y Descripción
                _buildSectionCard(
                  title: 'Ubicación y detalles',
                  icon: Icons.place_outlined,
                  children: [
                    TextFormField(
                      controller: _locationController,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        labelText: 'Ubicación (dirección) *',
                        hintText: 'Ej. Av. Universidad 123, Col. Centro',
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Ingresa la ubicación o dirección';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration(
                        labelText: 'Descripción',
                        hintText:
                            'Describe el espacio, qué incluye, reglas de convivencia, etc.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sección 3: Servicios incluidos
                _buildSectionCard(
                  title: 'Servicios incluidos',
                  icon: Icons.check_circle_outline_rounded,
                  children: [
                    const Text(
                      'Selecciona los servicios que incluye el alojamiento:',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableServices.map((service) {
                        final id = service['id'] as String;
                        final label = service['label'] as String;
                        final icon = service['icon'] as IconData;
                        final isSelected = _selectedServices.contains(id);

                        return FilterChip(
                          avatar: Icon(
                            icon,
                            size: 18,
                            color: isSelected
                                ? AppColors.blanco
                                : AppColors.terracota,
                          ),
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedServices.add(id);
                              } else {
                                _selectedServices.remove(id);
                              }
                            });
                          },
                          selectedColor: AppColors.salvia,
                          backgroundColor: AppColors.blanco,
                          labelStyle: TextStyle(
                            color: isSelected
                                ? AppColors.blanco
                                : AppColors.texto,
                            fontWeight: FontWeight.w600,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.salvia
                                : AppColors.salvia.withValues(alpha: 0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Sección 4: Fotografías (URLs con https://)
                _buildSectionCard(
                  title: 'Fotografías de la propiedad',
                  icon: Icons.photo_library_outlined,
                  trailing: Text(
                    '${vm.photoUrls.length}/${PublishPropertyViewModel.maxPhotos}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: vm.photoUrls.isEmpty
                          ? AppColors.errorTexto
                          : AppColors.terracota,
                    ),
                  ),
                  children: [
                    const Text(
                      'Agrega de 1 a 3 fotos pegando el enlace web seguro (debe comenzar con https://):',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.texto,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Campo de texto para pegar enlace + botón para agregarla
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _photoUrlController,
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _addPhoto(vm),
                            decoration: _inputDecoration(
                              labelText: 'Pega el enlace de una foto',
                              hintText: 'https://ejemplo.com/foto.jpg',
                              prefixIcon: Icons.link_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            onPressed: vm.photoUrls.length >=
                                    PublishPropertyViewModel.maxPhotos
                                ? null
                                : () => _addPhoto(vm),
                            icon: const Icon(Icons.add, size: 20),
                            label: const Text('Agregar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.terracota,
                              disabledBackgroundColor:
                                  AppColors.terracota.withValues(alpha: 0.4),
                              foregroundColor: AppColors.blanco,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Vista previa de fotos agregadas con Image.network y errorBuilder
                    if (vm.photoUrls.isNotEmpty) ...[
                      const Text(
                        'Fotos agregadas:',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.texto,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ...vm.photoUrls.asMap().entries.map((entry) {
                            final index = entry.key;
                            final url = entry.value;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    width: 95,
                                    height: 95,
                                    color:
                                        AppColors.arena.withValues(alpha: 0.5),
                                    child: Image.network(
                                      url,
                                      width: 95,
                                      height: 95,
                                      fit: BoxFit.cover,
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.salvia,
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: 95,
                                          height: 95,
                                          color: AppColors.errorFondo,
                                          padding: const EdgeInsets.all(6),
                                          child: const Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.broken_image_outlined,
                                                color: AppColors.errorTexto,
                                                size: 26,
                                              ),
                                              SizedBox(height: 4),
                                              Text(
                                                'No carga',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: AppColors.errorTexto,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: -6,
                                  right: -6,
                                  child: GestureDetector(
                                    onTap: () => vm.removePhotoUrl(index),
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: AppColors.terracota,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: AppColors.blanco,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 28),

                // Botón Publicar
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: vm.isLoading
                        ? null
                        : () => _submit(context, vm, user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.terracota,
                      disabledBackgroundColor:
                          AppColors.terracota.withValues(alpha: 0.6),
                      foregroundColor: AppColors.blanco,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: vm.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.blanco,
                            ),
                          )
                        : const Text(
                            'Publicar propiedad',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    Widget? trailing,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blanco,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.texto.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: AppColors.terracota),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.texto,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const Divider(height: 20),
          ...children,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    String? suffixText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      suffixText: suffixText,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: AppColors.salvia, size: 20)
          : null,
      labelStyle: const TextStyle(color: AppColors.texto, fontSize: 14),
      hintStyle: const TextStyle(color: AppColors.hintTexto, fontSize: 13),
      filled: true,
      fillColor: AppColors.blanco,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.bordeInput),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.terracota, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorTexto),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorTexto, width: 1.5),
      ),
    );
  }
}
