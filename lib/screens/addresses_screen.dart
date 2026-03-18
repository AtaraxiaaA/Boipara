import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Bangladesh Geo Data ───────────────────────────────────────────────────
const Map<String, Map<String, List<String>>> bdGeoData = {
  'Dhaka': {
    'Dhaka': [
      'Dhanmondi',
      'Gulshan',
      'Banani',
      'Mirpur',
      'Uttara',
      'Mohammadpur',
      'Tejgaon',
      'Motijheel',
      'Wari',
      'Lalbagh',
      'Demra',
      'Kadamtali',
      'Kotwali',
      'Sutrapur',
      'Pallabi',
      'Sabujbagh',
      'Shyampur',
      'Turag',
      'Badda',
      'Khilgaon',
      'Khilkhet',
      'Rampura',
      'Vatara',
    ],
    'Gazipur': [
      'Gazipur Sadar',
      'Kaliakair',
      'Kaliganj',
      'Kapasia',
      'Sreepur',
      'Tongi',
    ],
    'Manikganj': [
      'Manikganj Sadar',
      'Daulatpur',
      'Ghior',
      'Harirampur',
      'Saturia',
      'Shivalaya',
      'Singair',
    ],
    'Munshiganj': [
      'Munshiganj Sadar',
      'Gazaria',
      'Lohajang',
      'Sirajdikhan',
      'Sreenagar',
      'Tongibari',
    ],
    'Narayanganj': [
      'Narayanganj Sadar',
      'Araihazar',
      'Bandar',
      'Rupganj',
      'Sonargaon',
    ],
    'Narsingdi': [
      'Narsingdi Sadar',
      'Belabo',
      'Monohardi',
      'Palash',
      'Raipura',
      'Shibpur',
    ],
    'Rajbari': [
      'Rajbari Sadar',
      'Baliakandi',
      'Goalanda',
      'Kalukhali',
      'Pangsha',
    ],
    'Faridpur': [
      'Faridpur Sadar',
      'Alfadanga',
      'Bhanga',
      'Boalmari',
      'Charbhadrasan',
      'Madhukhali',
      'Nagarkanda',
      'Sadarpur',
      'Saltha',
    ],
    'Gopalganj': [
      'Gopalganj Sadar',
      'Kashiani',
      'Kotalipara',
      'Muksudpur',
      'Tungipara',
    ],
    'Madaripur': ['Madaripur Sadar', 'Kalkini', 'Rajoir', 'Shibchar'],
    'Shariatpur': [
      'Shariatpur Sadar',
      'Bhedarganj',
      'Damudya',
      'Gosairhat',
      'Naria',
      'Zajira',
    ],
    'Tangail': [
      'Tangail Sadar',
      'Basail',
      'Bhuapur',
      'Delduar',
      'Dhanbari',
      'Ghatail',
      'Gopalpur',
      'Kalihati',
      'Madhupur',
      'Mirzapur',
      'Nagarpur',
      'Sakhipur',
    ],
    'Kishoreganj': [
      'Kishoreganj Sadar',
      'Austagram',
      'Bajitpur',
      'Bhairab',
      'Hossainpur',
      'Itna',
      'Karimganj',
      'Katiadi',
      'Kuliarchar',
      'Mithamain',
      'Nikli',
      'Pakundia',
      'Tarail',
    ],
  },
  'Chattogram': {
    'Chattogram': [
      'Agrabad',
      'Bayazid',
      'Chandgaon',
      'Chawkbazar',
      'Doublemooring',
      'Halishahar',
      'Karnaphuli',
      'Khulshi',
      'Kotwali',
      'Pahartali',
      'Panchlaish',
      'Patenga',
      'Sitakunda',
      'Akbarsha',
      'Bakalia',
      'Banshkhali',
      'Boalkhali',
      'Fatikchhari',
      'Hathazari',
      'Lohagara',
      'Mirsharai',
      'Patiya',
      'Rangunia',
      'Raozan',
      'Sandwip',
      'Satkania',
    ],
    'Cox\'s Bazar': [
      'Cox\'s Bazar Sadar',
      'Chakaria',
      'Kutubdia',
      'Maheshkhali',
      'Pekua',
      'Ramu',
      'Teknaf',
      'Ukhia',
    ],
    'Feni': [
      'Feni Sadar',
      'Chhagalnaiya',
      'Daganbhuiyan',
      'Parshuram',
      'Sonagazi',
      'Fulgazi',
    ],
    'Comilla': [
      'Comilla Sadar',
      'Barura',
      'Brahmanpara',
      'Burichang',
      'Chandina',
      'Chauddagram',
      'Daudkandi',
      'Debidwar',
      'Homna',
      'Laksam',
      'Lalmai',
      'Meghna',
      'Monoharganj',
      'Muradnagar',
      'Nangalkot',
      'Titas',
    ],
    'Brahmanbaria': [
      'Brahmanbaria Sadar',
      'Akhaura',
      'Ashuganj',
      'Bancharampur',
      'Bijoynagar',
      'Kasba',
      'Nabinagar',
      'Nasirnagar',
      'Sarail',
    ],
    'Chandpur': [
      'Chandpur Sadar',
      'Faridganj',
      'Haimchar',
      'Haziganj',
      'Kachua',
      'Matlab North',
      'Matlab South',
      'Shahrasti',
    ],
    'Lakshmipur': [
      'Lakshmipur Sadar',
      'Kamalnagar',
      'Ramganj',
      'Ramgati',
      'Raipur',
    ],
    'Noakhali': [
      'Noakhali Sadar',
      'Begumganj',
      'Chatkhil',
      'Companiganj',
      'Hatiya',
      'Kabirhat',
      'Senbagh',
      'Sonaimuri',
      'Suborna Char',
    ],
    'Khagrachhari': [
      'Khagrachhari Sadar',
      'Dighinala',
      'Lakshmichhari',
      'Mahalchhari',
      'Manikchhari',
      'Matiranga',
      'Panchhari',
      'Ramgarh',
    ],
    'Rangamati': [
      'Rangamati Sadar',
      'Bagaichhari',
      'Barkal',
      'Belaichhari',
      'Juraichhari',
      'Kaptai',
      'Kaukhali',
      'Langadu',
      'Naniarchar',
      'Rajasthali',
    ],
    'Bandarban': [
      'Bandarban Sadar',
      'Alikadam',
      'Lama',
      'Naikhongchhari',
      'Rowangchhari',
      'Ruma',
      'Thanchi',
    ],
  },
  'Rajshahi': {
    'Rajshahi': [
      'Rajshahi Sadar',
      'Bagha',
      'Bagmara',
      'Charghat',
      'Durgapur',
      'Godagari',
      'Mohanpur',
      'Paba',
      'Puthia',
      'Tanore',
    ],
    'Chapai Nawabganj': [
      'Chapai Nawabganj Sadar',
      'Bholahat',
      'Gomastapur',
      'Nachole',
      'Shibganj',
    ],
    'Joypurhat': [
      'Joypurhat Sadar',
      'Akkelpur',
      'Kalai',
      'Khetlal',
      'Panchbibi',
    ],
    'Naogaon': [
      'Naogaon Sadar',
      'Atrai',
      'Badalgachhi',
      'Dhamoirhat',
      'Mahadebpur',
      'Manda',
      'Mohadevpur',
      'Niamatpur',
      'Patnitala',
      'Porsha',
      'Raninagar',
      'Sapahar',
    ],
    'Natore': [
      'Natore Sadar',
      'Bagatipara',
      'Baraigram',
      'Gurudaspur',
      'Lalpur',
      'Singra',
    ],
    'Pabna': [
      'Pabna Sadar',
      'Atgharia',
      'Bera',
      'Bhangura',
      'Chatmohar',
      'Faridpur',
      'Ishwardi',
      'Santhia',
      'Sujanagar',
    ],
    'Sirajganj': [
      'Sirajganj Sadar',
      'Belkuchi',
      'Chauhali',
      'Kamarkhanda',
      'Kazipur',
      'Raiganj',
      'Shahjadpur',
      'Tarash',
      'Ullapara',
    ],
    'Bogura': [
      'Bogura Sadar',
      'Adamdighi',
      'Dhunat',
      'Dhupchanchia',
      'Gabtali',
      'Kahaloo',
      'Nandigram',
      'Sariakandi',
      'Shajahanpur',
      'Sherpur',
      'Shibganj',
      'Sonatala',
    ],
  },
  'Khulna': {
    'Khulna': [
      'Khulna Sadar',
      'Batiaghata',
      'Dacope',
      'Dighalia',
      'Dumuria',
      'Koyra',
      'Paikgachha',
      'Phultala',
      'Rupsa',
      'Terokhada',
      'Daulatpur',
      'Khan Jahan Ali',
      'Sonadanga',
    ],
    'Bagerhat': [
      'Bagerhat Sadar',
      'Chitalmari',
      'Fakirhat',
      'Kachua',
      'Mollahat',
      'Mongla',
      'Morrelganj',
      'Rampal',
      'Sarankhola',
    ],
    'Chuadanga': ['Chuadanga Sadar', 'Alamdanga', 'Damurhuda', 'Jibannagar'],
    'Jessore': [
      'Jessore Sadar',
      'Abhaynagar',
      'Bagherpara',
      'Chaugachha',
      'Jhikargachha',
      'Keshabpur',
      'Manirampur',
      'Sharsha',
    ],
    'Jhenaidah': [
      'Jhenaidah Sadar',
      'Harinakunda',
      'Kaliganj',
      'Kotchandpur',
      'Maheshpur',
      'Shailkupa',
    ],
    'Kushtia': [
      'Kushtia Sadar',
      'Bheramara',
      'Daulatpur',
      'Khoksa',
      'Kumarkhali',
      'Mirpur',
    ],
    'Magura': ['Magura Sadar', 'Mohammadpur', 'Shalikha', 'Sreepur'],
    'Meherpur': ['Meherpur Sadar', 'Gangni', 'Mujibnagar'],
    'Narail': ['Narail Sadar', 'Kalia', 'Lohagara'],
    'Satkhira': [
      'Satkhira Sadar',
      'Assasuni',
      'Debhata',
      'Kalaroa',
      'Kaliganj',
      'Shyamnagar',
      'Tala',
    ],
  },
  'Barisal': {
    'Barisal': [
      'Barisal Sadar',
      'Agailjhara',
      'Babuganj',
      'Bakerganj',
      'Banaripara',
      'Gaurnadi',
      'Hizla',
      'Mehendiganj',
      'Muladi',
      'Uzirpur',
    ],
    'Bhola': [
      'Bhola Sadar',
      'Borhanuddin',
      'Charfasson',
      'Daulatkhan',
      'Lalmohan',
      'Manpura',
      'Tazumuddin',
    ],
    'Jhalokati': ['Jhalokati Sadar', 'Kathalia', 'Nalchity', 'Rajapur'],
    'Patuakhali': [
      'Patuakhali Sadar',
      'Bauphal',
      'Dashmina',
      'Dumki',
      'Galachipa',
      'Kalapara',
      'Mirzaganj',
      'Rangabali',
    ],
    'Pirojpur': [
      'Pirojpur Sadar',
      'Bhandaria',
      'Kawkhali',
      'Mathbaria',
      'Nazirpur',
      'Nesarabad',
      'Zianagar',
    ],
    'Barguna': [
      'Barguna Sadar',
      'Amtali',
      'Bamna',
      'Betagi',
      'Patharghata',
      'Taltali',
    ],
  },
  'Sylhet': {
    'Sylhet': [
      'Sylhet Sadar',
      'Balaganj',
      'Beani Bazar',
      'Bishwanath',
      'Companiganj',
      'Fenchuganj',
      'Golapganj',
      'Gowainghat',
      'Jaintiapur',
      'Kanaighat',
      'Osmaninagar',
      'South Surma',
      'Zakiganj',
    ],
    'Habiganj': [
      'Habiganj Sadar',
      'Ajmiriganj',
      'Bahubal',
      'Baniachong',
      'Chunarughat',
      'Lakhai',
      'Madhabpur',
      'Nabiganj',
    ],
    'Moulvibazar': [
      'Moulvibazar Sadar',
      'Barlekha',
      'Juri',
      'Kamalganj',
      'Kulaura',
      'Rajnagar',
      'Sreemangal',
    ],
    'Sunamganj': [
      'Sunamganj Sadar',
      'Bishwamvarpur',
      'Chhatak',
      'Derai',
      'Dharampasha',
      'Dowarabazar',
      'Jagannathpur',
      'Jamalganj',
      'Sullah',
      'Tahirpur',
    ],
  },
  'Rangpur': {
    'Rangpur': [
      'Rangpur Sadar',
      'Badarganj',
      'Gangachara',
      'Kaunia',
      'Mithapukur',
      'Pirgachha',
      'Pirganj',
      'Taraganj',
    ],
    'Dinajpur': [
      'Dinajpur Sadar',
      'Birampur',
      'Birganj',
      'Biral',
      'Bochaganj',
      'Chirirbandar',
      'Ghoraghat',
      'Hakimpur',
      'Kaharole',
      'Khansama',
      'Nawabganj',
      'Parbatipur',
      'Phulbari',
    ],
    'Gaibandha': [
      'Gaibandha Sadar',
      'Phulchhari',
      'Gobindaganj',
      'Palashbari',
      'Sadullapur',
      'Sughatta',
      'Sundarganj',
    ],
    'Kurigram': [
      'Kurigram Sadar',
      'Bhurungamari',
      'Char Rajibpur',
      'Chilmari',
      'Nageshwari',
      'Phulbari',
      'Rajarhat',
      'Raumari',
      'Ulipur',
    ],
    'Lalmonirhat': [
      'Lalmonirhat Sadar',
      'Aditmari',
      'Hatibandha',
      'Kaliganj',
      'Patgram',
    ],
    'Nilphamari': [
      'Nilphamari Sadar',
      'Dimla',
      'Domar',
      'Jaldhaka',
      'Kishoreganj',
      'Saidpur',
    ],
    'Panchagarh': ['Panchagarh Sadar', 'Atwari', 'Boda', 'Debiganj', 'Tetulia'],
    'Thakurgaon': [
      'Thakurgaon Sadar',
      'Baliadangi',
      'Haripur',
      'Pirganj',
      'Ranisankail',
    ],
  },
  'Mymensingh': {
    'Mymensingh': [
      'Mymensingh Sadar',
      'Bhaluka',
      'Dhobaura',
      'Fulbaria',
      'Gaffargaon',
      'Gauripur',
      'Haluaghat',
      'Ishwarganj',
      'Muktagachha',
      'Nandail',
      'Phulpur',
      'Trishal',
    ],
    'Jamalpur': [
      'Jamalpur Sadar',
      'Bakshiganj',
      'Dewanganj',
      'Islampur',
      'Madarganj',
      'Melandaha',
      'Sarishabari',
    ],
    'Netrokona': [
      'Netrokona Sadar',
      'Atpara',
      'Barhatta',
      'Durgapur',
      'Kalmakanda',
      'Kendua',
      'Khaliajuri',
      'Madan',
      'Mohanganj',
      'Purbadhala',
    ],
    'Sherpur': [
      'Sherpur Sadar',
      'Jhenaigati',
      'Nakla',
      'Nalitabari',
      'Sreebardi',
    ],
  },
};

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  static const brown = Color(0xFF613613);
  static const accentOrange = Color(0xFFE07B39);

  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  String _profilePhone = '';

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get _addressesRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_uid)
      .collection('addresses');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load profile phone
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .get();
      if (userDoc.exists) {
        _profilePhone = userDoc.data()?['mobile'] ?? '';
      }

      // Load addresses
      final snapshot = await _addressesRef.get();
      setState(() {
        _addresses = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      _showError('Failed to load addresses');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(String id) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var addr in _addresses) {
        batch.update(_addressesRef.doc(addr['id']), {
          'isDefault': addr['id'] == id,
        });
      }
      await batch.commit();
      setState(() {
        for (var a in _addresses) {
          a['isDefault'] = a['id'] == id;
        }
      });
      _showSuccess('Default address updated');
    } catch (e) {
      _showError('Failed to update default');
    }
  }

  Future<void> _deleteAddress(String id) async {
    try {
      await _addressesRef.doc(id).delete();
      setState(() => _addresses.removeWhere((a) => a['id'] == id));
      _showSuccess('Address deleted');
    } catch (e) {
      _showError('Failed to delete address');
    }
  }

  void _showAddressSheet({Map<String, dynamic>? existing}) {
    final isEdit = existing != null;

    final labelController = TextEditingController(
      text: existing?['label'] ?? '',
    );
    final nameController = TextEditingController(text: existing?['name'] ?? '');
    final backup1Controller = TextEditingController(
      text: existing?['backup1'] ?? '+88',
    );
    final backup2Controller = TextEditingController(
      text: existing?['backup2'] ?? '+88',
    );
    final streetController = TextEditingController(
      text: existing?['street'] ?? '',
    );
    final postalController = TextEditingController(
      text: existing?['postalCode'] ?? '',
    );
    final formKey = GlobalKey<FormState>();

    String? selectedDivision = existing?['division'];
    String? selectedDistrict = existing?['district'];
    String? selectedUpazila = existing?['upazila'];
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final districts = selectedDivision != null
              ? bdGeoData[selectedDivision]!.keys.toList()
              : <String>[];
          final upazilas =
              (selectedDivision != null && selectedDistrict != null)
              ? bdGeoData[selectedDivision]![selectedDistrict] ?? <String>[]
              : <String>[];

          return Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              top: 24,
              left: 24,
              right: 24,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    Text(
                      isEdit ? 'Edit Address' : 'Add New Address',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: brown,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Label
                    _sheetField(
                      controller: labelController,
                      label: 'Label',
                      hint: 'e.g. Home, Office, University',
                      icon: Icons.label_outline_rounded,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Label is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Full Name
                    _sheetField(
                      controller: nameController,
                      label: 'Full Name',
                      hint: 'Recipient name',
                      icon: Icons.person_outline_rounded,
                      validator: (v) =>
                          v!.trim().isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 14),

                    // Primary phone (read-only from profile)
                    _sheetLabel('Primary Phone', Icons.phone_outlined),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            size: 14,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _profilePhone.isNotEmpty
                                ? _profilePhone
                                : 'No phone in profile',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Change primary phone from Edit Profile',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Backup numbers
                    _sheetField(
                      controller: backup1Controller,
                      label: 'Backup Phone 1 (optional)',
                      hint: '+880 1XXX-XXXXXX',
                      icon: Icons.phone_callback_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 14),
                    _sheetField(
                      controller: backup2Controller,
                      label: 'Backup Phone 2 (optional)',
                      hint: '+880 1XXX-XXXXXX',
                      icon: Icons.phone_callback_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 20),

                    // Division picker
                    _sheetLabel('Division', Icons.map_outlined),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: selectedDivision,
                      hint: 'Select Division',
                      items: bdGeoData.keys.toList(),
                      onChanged: (val) {
                        setSheetState(() {
                          selectedDivision = val;
                          selectedDistrict = null;
                          selectedUpazila = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // District picker
                    _sheetLabel('District', Icons.location_city_outlined),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: selectedDistrict,
                      hint: selectedDivision == null
                          ? 'Select division first'
                          : 'Select District',
                      items: districts,
                      enabled: selectedDivision != null,
                      onChanged: (val) {
                        setSheetState(() {
                          selectedDistrict = val;
                          selectedUpazila = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Upazila picker
                    _sheetLabel('Upazila / Thana', Icons.place_outlined),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: selectedUpazila,
                      hint: selectedDistrict == null
                          ? 'Select district first'
                          : 'Select Upazila',
                      items: upazilas,
                      enabled: selectedDistrict != null,
                      onChanged: (val) {
                        setSheetState(() => selectedUpazila = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Street address
                    _sheetField(
                      controller: streetController,
                      label: 'Street / House / Road',
                      hint: 'House no, Road, Block...',
                      icon: Icons.home_outlined,
                      maxLines: 2,
                      validator: (v) => v!.trim().isEmpty
                          ? 'Street address is required'
                          : null,
                    ),
                    const SizedBox(height: 14),

                    // Postal code
                    _sheetField(
                      controller: postalController,
                      label: 'Postal Code',
                      hint: 'e.g. 1207',
                      icon: Icons.markunread_mailbox_outlined,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                if (selectedDivision == null ||
                                    selectedDistrict == null ||
                                    selectedUpazila == null) {
                                  _showError(
                                    'Please select Division, District and Upazila',
                                  );
                                  return;
                                }
                                setSheetState(() => isSaving = true);
                                try {
                                  final data = {
                                    'label': labelController.text.trim(),
                                    'name': nameController.text.trim(),
                                    'phone': _profilePhone,
                                    'backup1': backup1Controller.text.trim(),
                                    'backup2': backup2Controller.text.trim(),
                                    'division': selectedDivision,
                                    'district': selectedDistrict,
                                    'upazila': selectedUpazila,
                                    'street': streetController.text.trim(),
                                    'postalCode': postalController.text.trim(),
                                    'isDefault': isEdit
                                        ? existing['isDefault']
                                        : _addresses.isEmpty,
                                    'createdAt': isEdit
                                        ? existing['createdAt']
                                        : FieldValue.serverTimestamp(),
                                  };

                                  if (isEdit) {
                                    await _addressesRef
                                        .doc(existing['id'])
                                        .update(data);
                                  } else {
                                    await _addressesRef.add(data);
                                  }

                                  if (context.mounted) Navigator.pop(context);
                                  await _loadData();
                                  _showSuccess(
                                    isEdit
                                        ? 'Address updated!'
                                        : 'Address added!',
                                  );
                                } catch (e) {
                                  setSheetState(() => isSaving = false);
                                  _showError('Failed to save address');
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: brown,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                isEdit ? 'Update Address' : 'Add Address',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(
            hint,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: enabled ? Colors.grey : Colors.grey.shade300,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, style: const TextStyle(fontSize: 13)),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
        ),
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> addr) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Address',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Remove "${addr['label']}" address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(addr['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0E9),
      appBar: AppBar(
        backgroundColor: brown,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Addresses',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddressSheet(),
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Address',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: brown))
          : _addresses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off_outlined,
                    size: 72,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No addresses yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tap "+ Add Address" to add one',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: _addresses.length,
              itemBuilder: (context, index) =>
                  _buildAddressCard(_addresses[index]),
            ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> addr) {
    final isDefault = addr['isDefault'] == true;
    final hasBackup1 = (addr['backup1'] ?? '').toString().isNotEmpty;
    final hasBackup2 = (addr['backup2'] ?? '').toString().isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isDefault
            ? Border.all(color: accentOrange, width: 1.5)
            : Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDefault
                        ? accentOrange.withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _labelIcon(addr['label'] ?? ''),
                        size: 14,
                        color: isDefault ? accentOrange : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        addr['label'] ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDefault ? accentOrange : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isDefault)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF059669).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Default',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _showAddressSheet(existing: addr),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: brown.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      size: 16,
                      color: brown,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _confirmDelete(addr),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      size: 16,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Text(
              addr['name'] ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),

            // Primary phone
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  addr['phone'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),

            // Backup phones
            if (hasBackup1) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.phone_callback_outlined,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    addr['backup1'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Text(
                    ' (backup)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
            if (hasBackup2) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.phone_callback_outlined,
                    size: 13,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    addr['backup2'],
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  Text(
                    ' (backup)',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),

            // Address
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        addr['street'] ?? '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        [addr['upazila'], addr['district'], addr['division']]
                            .where((e) => e != null && e.toString().isNotEmpty)
                            .join(', '),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      if ((addr['postalCode'] ?? '').toString().isNotEmpty)
                        Text(
                          'Postal: ${addr['postalCode']}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            if (!isDefault) ...[
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _setDefault(addr['id']),
                child: Row(
                  children: [
                    Icon(
                      Icons.radio_button_unchecked,
                      size: 16,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Set as default',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _labelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
      case 'work':
        return Icons.work_outline_rounded;
      case 'university':
      case 'school':
        return Icons.school_rounded;
      default:
        return Icons.location_on_outlined;
    }
  }

  Widget _sheetLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _sheetField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sheetLabel(label, icon),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: brown, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
