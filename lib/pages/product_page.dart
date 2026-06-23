import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  List<ProductModel> products = [];
  int totalProducts = 0;

  Future<void> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = prefs.getStringList('products') ?? [];
    setState(() {
      products = productList
          .map((json) => ProductModel.fromJsonString(json))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadInitialProducts();
  }

  Future<void> _loadInitialProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productList = prefs.getStringList('products') ?? [];

    if (productList.isEmpty) {
      setState(() {
        totalProducts = products.length;
      });

      // Save sample products to SharedPreferences
      List<String> productlist = products
          .map((product) => product.toJsonString())
          .toList();
      await prefs.setStringList('products', productlist);
    } else {
      // Load existing products
      setState(() {
        products = productList
            .map((json) => ProductModel.fromJsonString(json))
            .toList();
        totalProducts = products.length;
      });
    }
  }

  Future<void> saveProducts() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> productlist = products
        .map((product) => product.toJsonString())
        .toList();
    await prefs.setStringList('products', productlist);
  }

  Future<void> addProduct(ProductModel product) async {
    setState(() {
      products.add(product);
      totalProducts = products.length;
    });
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully!')),
    );
  }

  Future<void> updateProduct(int index, ProductModel updatedProduct) async {
    setState(() {
      products[index] = updatedProduct;
    });
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product updated successfully!')),
    );
  }

  Future<void> deleteProduct(int index) async {
    setState(() {
      products.removeAt(index);
      totalProducts = products.length;
    });
    await saveProducts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully!')),
    );
  }

  Future<String> convertImageToBase64(XFile image) async {
    Uint8List imageBytes = await image.readAsBytes();
    return base64Encode(imageBytes);
  }

  void showForm({ProductModel? product, int? index}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product != null ? product.price.toString() : '',
    );

    XFile? selectedImage;
    final ImagePicker picker = ImagePicker();

    Future<void> pickImage(StateSetter setDialogState) async {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setDialogState(() {
          selectedImage = image;
        });
      }
    }

    Widget buildImagePreview() {
      if (selectedImage != null) {
        return FutureBuilder<Uint8List>(
          future: selectedImage!.readAsBytes(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                snapshot.data!,
                width: 150,
                height: 150,
                fit: BoxFit.cover,
              ),
            );
          },
        );
      }

      if (product?.image != null && product!.image!.isNotEmpty) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            base64Decode(product.image!),
            width: 150,
            height: 150,
            fit: BoxFit.cover,
          ),
        );
      }

      return const SizedBox.shrink();
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(product == null ? 'TAMBAH PRODUCT' : 'EDIT PRODUCT'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  TextField(
                    controller: priceController,
                    decoration: const InputDecoration(labelText: 'Price'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton.icon(
                    onPressed: () => pickImage(setDialogState),
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text('Pilih Gambar'),
                  ),
                  const SizedBox(height: 10),
                  Center(child: buildImagePreview()),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  String imageBase64 = product?.image ?? "";
                  if (selectedImage != null) {
                    imageBase64 = await convertImageToBase64(selectedImage!);
                  }
                  final newProduct = ProductModel(
                    id: product?.id ?? DateTime.now().toString(),
                    name: nameController.text,
                    description: descriptionController.text,
                    price: double.tryParse(priceController.text) ?? 0.0,
                    image: imageBase64,
                  );
                  if (product == null) {
                    addProduct(newProduct);
                  } else {
                    setState(() {
                      products[index!] = newProduct;
                    });
                    saveProducts();
                  }
                  if (!context.mounted) return;
                  Navigator.pop(context);
                },
                child: Text(product == null ? 'Add' : 'Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Produk', style: TextStyle(fontSize: 18)),
        backgroundColor: const Color.fromARGB(255, 126, 209, 128),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => showForm(),
                    icon: const Icon(Icons.add),
                    label: const Text('Tambah Produk'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: products.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada produk. Tekan "Tambah Produk" untuk menambahkan.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: ListTile(
                            leading: product.image != null && product.image!.isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      base64Decode(product.image!),
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(Icons.image, size: 50),
                            title: Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(product.description),
                            trailing: Text(
                              'Rp ${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onTap: () =>
                                showForm(product: product, index: index),
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Hapus Produk'),
                                  content: Text(
                                    'Apakah Anda yakin ingin menghapus "${product.name}"?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Batal'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        deleteProduct(index);
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Hapus'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
