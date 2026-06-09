import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      // Add sample products if none exist
      final sampleProducts = [
        ProductModel(
          id: '1',
          name: 'Laptop',
          description: 'Laptop gaming dengan spesifikasi tinggi',
          price: 15000000.0,
        ),
        ProductModel(
          id: '2',
          name: 'Smartphone',
          description: 'Smartphone flagship dengan kamera 108MP',
          price: 8000000.0,
        ),
        ProductModel(
          id: '3',
          name: 'Tablet',
          description: 'Tablet untuk produktivitas dan hiburan',
          price: 5000000.0,
        ),
        ProductModel(
          id: '4',
          name: 'Headphone',
          description: 'Headphone wireless dengan noise cancellation',
          price: 2000000.0,
        ),
        ProductModel(
          id: '5',
          name: 'Smartwatch',
          description: 'Smartwatch dengan fitur kesehatan',
          price: 3000000.0,
        ),
      ];

      setState(() {
        products = sampleProducts;
        totalProducts = products.length;
      });

      // Save sample products to SharedPreferences
      List<String> productlist = sampleProducts
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added successfully!')),
    );
  }

  Future<void> updateProduct(int index, ProductModel updatedProduct) async {
    setState(() {
      products[index] = updatedProduct;
    });
    await saveProducts();
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product deleted successfully!')),
    );
  }

  void showForm({ProductModel? product, int? index}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final descriptionController = TextEditingController(
      text: product?.description ?? '',
    );
    final priceController = TextEditingController(
      text: product != null ? product.price.toString() : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'TAMBAH PRODUCT' : 'EDIT PRODUCT'),
        content: SingleChildScrollView(
          child: Column(
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
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newProduct = ProductModel(
                id: product?.id ?? DateTime.now().toString(),
                name: nameController.text,
                description: descriptionController.text,
                price: double.tryParse(priceController.text) ?? 0.0,
              );
              if (product == null) {
                addProduct(newProduct);
              } else {
                setState(() {
                  products[index!] = newProduct;
                });
                saveProducts();
              }
              Navigator.pop(context);
            },
            child: Text(product == null ? 'Add' : 'Save'),
          ),
        ],
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
