import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/machine_listing.dart';
import '../../models/app_user.dart';
import '../constants/firebase_constants.dart';

/// Seeds Firestore with realistic mock data for development.
/// Call once, then remove the trigger.
class SeedData {
  static final _firestore = FirebaseFirestore.instance;

  static Future<void> seed() async {
    const sellerId = 'seed_seller_001';

    // Check if already seeded
    final existing = await _firestore
        .collection(FirebaseConstants.listingsCollection)
        .where('sellerId', isEqualTo: sellerId)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return; // Already seeded

    // Create seller user document
    final now = DateTime.now();
    final seller = AppUser(
      uid: sellerId,
      email: 'demo@537machines.com',
      firstName: 'James',
      lastName: 'Mitchell',
      company: 'Industrial Supply Co.',
      phone: '+1 (555) 234-5678',
      location: 'Houston, TX',
      bio: 'Leading supplier of industrial machinery since 1998.',
      createdAt: now,
    );

    await _firestore
        .collection(FirebaseConstants.usersCollection)
        .doc(sellerId)
        .set(seller.toJson());

    // Create listings
    final listings = [
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'Haas VF-2 CNC Vertical Mill',
        description:
            'Haas VF-2 CNC Vertical Machining Center in excellent working condition. '
            'Features a 30x16x20 inch travel, 8100 RPM spindle, 20-pocket tool changer, '
            'and 4th axis ready. Recently serviced with new way covers. '
            'Includes Renishaw probing system and chip conveyor.',
        category: 'CNC Machines',
        price: 42500,
        condition: 'Used',
        location: 'Houston, TX',
        brand: 'Haas',
        model: 'VF-2',
        year: 2019,
        hours: 4200,
        imageUrls: [
          'https://picsum.photos/seed/cnc1/800/600',
          'https://picsum.photos/seed/cnc2/800/600',
        ],
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'Caterpillar D6 Dozer',
        description:
            'CAT D6 Track-Type Tractor with 6-way blade. Undercarriage at 70%. '
            'AC cabin, rear ripper, GPS grade control ready. Engine recently rebuilt '
            'with all maintenance records available. Runs strong, no leaks.',
        category: 'Construction Equipment',
        price: 185000,
        condition: 'Used',
        location: 'Dallas, TX',
        brand: 'Caterpillar',
        model: 'D6',
        year: 2017,
        hours: 6800,
        imageUrls: [
          'https://picsum.photos/seed/dozer1/800/600',
          'https://picsum.photos/seed/dozer2/800/600',
        ],
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'Komatsu PC200-8 Excavator',
        description:
            'Komatsu PC200-8 hydraulic excavator with quick coupler and 42" bucket. '
            'Cab has AC, heated seat, and rear camera. Tracks at 60%. '
            'Boom and stick cylinders recently resealed. Strong machine, ready to work.',
        category: 'Construction Equipment',
        price: 95000,
        condition: 'Used',
        location: 'Phoenix, AZ',
        brand: 'Komatsu',
        model: 'PC200-8',
        year: 2018,
        hours: 5400,
        imageUrls: [
          'https://picsum.photos/seed/excavator1/800/600',
        ],
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'Lincoln Electric Power MIG 256',
        description:
            'Lincoln Power MIG 256 welder, barely used. Comes with gun, ground clamp, '
            'gas regulator, and welding cart. 30-300 amp range, dual voltage 208/230V. '
            'Perfect for fabrication shops or field work.',
        category: 'Welding Equipment',
        price: 3200,
        condition: 'New',
        location: 'Chicago, IL',
        brand: 'Lincoln Electric',
        model: 'Power MIG 256',
        year: 2024,
        imageUrls: [
          'https://picsum.photos/seed/welder1/800/600',
        ],
        createdAt: now.subtract(const Duration(hours: 6)),
        updatedAt: now.subtract(const Duration(hours: 6)),
      ),
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'DMG MORI NLX 2500 CNC Lathe',
        description:
            'DMG MORI NLX 2500/700 CNC turning center with live tooling and sub-spindle. '
            'CELOS control with 15" touchscreen. 10" chuck, 26" max turning diameter. '
            'Bar feeder ready. Low hours, full maintenance history.',
        category: 'Lathes',
        price: 125000,
        condition: 'Refurbished',
        location: 'Detroit, MI',
        brand: 'DMG MORI',
        model: 'NLX 2500/700',
        year: 2020,
        hours: 2100,
        imageUrls: [
          'https://picsum.photos/seed/lathe1/800/600',
          'https://picsum.photos/seed/lathe2/800/600',
        ],
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'John Deere 310SL Backhoe Loader',
        description:
            'John Deere 310SL backhoe loader with extendable stick. 4WD, cab with heat/AC, '
            'pilot controls, ride control. Front bucket and rear bucket included. '
            'Well maintained, one owner since new.',
        category: 'Construction Equipment',
        price: 72000,
        condition: 'Used',
        location: 'Atlanta, GA',
        brand: 'John Deere',
        model: '310SL',
        year: 2016,
        hours: 4800,
        imageUrls: [
          'https://picsum.photos/seed/backhoe1/800/600',
        ],
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'Atlas Copco GA 30+ Rotary Screw Compressor',
        description:
            'Atlas Copco GA 30+ oil-injected rotary screw compressor. '
            '40 HP, 125 PSI, 130 CFM. Integrated dryer and filters. '
            'Very low hours, factory maintained. Energy-efficient VSD drive.',
        category: 'Compressors',
        price: 18500,
        condition: 'Refurbished',
        location: 'Denver, CO',
        brand: 'Atlas Copco',
        model: 'GA 30+ VSD',
        year: 2021,
        hours: 3200,
        imageUrls: [
          'https://picsum.photos/seed/compressor1/800/600',
        ],
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      MachineListing(
        id: '',
        sellerId: sellerId,
        sellerName: 'James Mitchell',
        title: 'Mazak Quick Turn 250MSY CNC Lathe',
        description:
            'Mazak QT 250MSY multi-tasking CNC lathe with milling, Y-axis, and sub-spindle. '
            'Mazatrol SmoothG CNC control. 10" chuck, 65mm bar capacity. '
            'Chip conveyor, parts catcher, and tool presetter included.',
        category: 'CNC Machines',
        price: 89000,
        condition: 'Used',
        location: 'Los Angeles, CA',
        brand: 'Mazak',
        model: 'Quick Turn 250MSY',
        year: 2018,
        hours: 7600,
        imageUrls: [
          'https://picsum.photos/seed/mazak1/800/600',
        ],
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    ];

    // Write all listings to Firestore
    final batch = _firestore.batch();
    for (final listing in listings) {
      final docRef = _firestore
          .collection(FirebaseConstants.listingsCollection)
          .doc();
      batch.set(docRef, listing.toJson());
    }
    await batch.commit();
  }
}
