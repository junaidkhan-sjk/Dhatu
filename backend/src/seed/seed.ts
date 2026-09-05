import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  console.log('[Seed] Starting database seeding with synthetic & demo datasets...');

  // 1. Clean existing records
  await prisma.anomalyFlag.deleteMany();
  await prisma.traceabilityRecord.deleteMany();
  await prisma.transaction.deleteMany();
  await prisma.material.deleteMany();
  await prisma.priceRecord.deleteMany();
  await prisma.auditLog.deleteMany();
  await prisma.user.deleteMany();
  await prisma.recycler.deleteMany();

  // 2. Seed Recyclers (12 Authorized & Verified Facilities across India)
  const recyclersData = [
    {
      id: 'rec-001',
      name: 'EcoMetals Green Yard Pvt Ltd',
      locationLat: 19.076,
      locationLng: 72.8777,
      address: 'Plot 42, Dharavi Link Road, Mumbai, Maharashtra 400017',
      materialsAccepted: JSON.stringify(['PCB', 'Battery', 'Cable', 'Motor']),
      authorizationDetails: 'MPCB/EW-REG/2024/0981 - Authorized Central Dismantler',
      authorizationStatus: 'authorized',
      phone: '+91 9876543211',
      email: 'operations@ecometals.in',
      offeredRatesJson: JSON.stringify({ PCB: 140, Battery: 88, Cable: 245, Motor: 200 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 35.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-002',
      name: 'Sahyadri E-Waste Recyclers',
      locationLat: 18.5204,
      locationLng: 73.8567,
      address: 'MIDC Phase II, Bhosari, Pune, Maharashtra 411026',
      materialsAccepted: JSON.stringify(['PCB', 'Battery', 'Cable', 'CRT', 'Motor']),
      authorizationDetails: 'MPCB/EW-REG/2023/1142 - High Capacity Smelting & Recovery',
      authorizationStatus: 'authorized',
      phone: '+91 9823012345',
      email: 'yard@sahyadrie-waste.com',
      offeredRatesJson: JSON.stringify({ PCB: 145, Battery: 90, Cable: 250, CRT: 35, Motor: 205 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 50.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-003',
      name: 'Navi Mumbai Precious Metal Extraction',
      locationLat: 19.033,
      locationLng: 73.0297,
      address: 'TTC Industrial Area, Rabale, Navi Mumbai 400701',
      materialsAccepted: JSON.stringify(['PCB', 'Cable']),
      authorizationDetails: 'CPCB/EW-REF/MUM-8874 - Certified PCB Hydrometallurgy',
      authorizationStatus: 'authorized',
      phone: '+91 9892110099',
      email: 'dispatch@navimumbaipm.in',
      offeredRatesJson: JSON.stringify({ PCB: 155, Cable: 235 }),
      pickupAvailable: false,
      serviceAreaRadiusKm: 25.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-004',
      name: 'Maharashtra Battery Safe Reclaim',
      locationLat: 19.2183,
      locationLng: 72.9781,
      address: 'Wagle Estate, Thane West, Maharashtra 400604',
      materialsAccepted: JSON.stringify(['Battery']),
      authorizationDetails: 'MPCB/HAZ-BATT/2025/0043 - Closed-Loop Lead & Li-Ion Neutralizer',
      authorizationStatus: 'authorized',
      phone: '+91 9769004411',
      email: 'support@mahabatterysafe.org',
      offeredRatesJson: JSON.stringify({ Battery: 95 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 40.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-005',
      name: 'Delhi NCR Eco-Smelters Hub',
      locationLat: 28.6139,
      locationLng: 77.209,
      address: 'Mayapuri Industrial Area Phase 1, New Delhi 110064',
      materialsAccepted: JSON.stringify(['PCB', 'Cable', 'Motor', 'CRT']),
      authorizationDetails: 'DPCC/EW-CERT/2024/7762 - Authorized Government E-Waste Partner',
      authorizationStatus: 'authorized',
      phone: '+91 9811099887',
      email: 'info@delhiecosmelters.com',
      offeredRatesJson: JSON.stringify({ PCB: 138, Cable: 242, Motor: 195, CRT: 40 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 60.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-006',
      name: 'Bengaluru CleanTech Circular Systems',
      locationLat: 12.9716,
      locationLng: 77.5946,
      address: 'Peenya Industrial Area 3rd Phase, Bengaluru, Karnataka 560058',
      materialsAccepted: JSON.stringify(['PCB', 'Battery', 'Cable', 'Motor']),
      authorizationDetails: 'KSPCB/EW-REG/BLR-5541 - ISO 14001 Certified Facility',
      authorizationStatus: 'authorized',
      phone: '+91 9980123987',
      email: 'intake@bengalurucleantech.in',
      offeredRatesJson: JSON.stringify({ PCB: 148, Battery: 92, Cable: 248, Motor: 202 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 45.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-007',
      name: 'Hyderabad Green Circuit Processors',
      locationLat: 17.385,
      locationLng: 78.4867,
      address: 'Jeedimetla Industrial Estate, Hyderabad, Telangana 500055',
      materialsAccepted: JSON.stringify(['PCB', 'Cable']),
      authorizationDetails: 'TSPCB/EW-LIC/2024/3391 - Registered Dismantling Unit',
      authorizationStatus: 'authorized',
      phone: '+91 9848011223',
      email: 'yard@greencircuit.co.in',
      offeredRatesJson: JSON.stringify({ PCB: 142, Cable: 238 }),
      pickupAvailable: false,
      serviceAreaRadiusKm: 30.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-008',
      name: 'Gujarat Apex Metal Recyclers',
      locationLat: 23.0225,
      locationLng: 72.5714,
      address: 'Vatva GIDC Phase IV, Ahmedabad, Gujarat 382445',
      materialsAccepted: JSON.stringify(['Cable', 'Motor', 'Battery']),
      authorizationDetails: 'GPCB/EW-COMP/2025/1109 - High Volume Non-Ferrous Refinery',
      authorizationStatus: 'authorized',
      phone: '+91 9825044556',
      email: 'procurement@gujarat-apex.com',
      offeredRatesJson: JSON.stringify({ Cable: 255, Motor: 210, Battery: 89 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 55.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-009',
      name: 'Chennai SafeCathode & CRT Neutralizer',
      locationLat: 13.0827,
      locationLng: 80.2707,
      address: 'Ambattur Industrial Estate, Chennai, Tamil Nadu 600058',
      materialsAccepted: JSON.stringify(['CRT', 'PCB', 'Motor']),
      authorizationDetails: 'TNPCB/HAZ-CRT/2024/9912 - Lead Glass Remediation Facility',
      authorizationStatus: 'authorized',
      phone: '+91 9840155667',
      email: 'ops@chennaicathode.org',
      offeredRatesJson: JSON.stringify({ CRT: 45, PCB: 135, Motor: 190 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 40.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-010',
      name: 'Kolkata Howrah E-Waste Hub',
      locationLat: 22.5726,
      locationLng: 88.3639,
      address: 'Baltikuri Industrial Complex, Howrah, West Bengal 711113',
      materialsAccepted: JSON.stringify(['PCB', 'Cable', 'Battery', 'CRT', 'Motor']),
      authorizationDetails: 'WBPCB/EW-REG/2023/4472 - Integrated Circular Dismantling Plant',
      authorizationStatus: 'authorized',
      phone: '+91 9830022334',
      email: 'contact@howrah-ewaste.in',
      offeredRatesJson: JSON.stringify({ PCB: 136, Cable: 236, Battery: 84, CRT: 32, Motor: 192 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 35.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-011',
      name: 'Shree Sai Unregistered Scrap Dealer',
      locationLat: 19.088,
      locationLng: 72.889,
      address: 'Kurla West Market, Mumbai 400070',
      materialsAccepted: JSON.stringify(['Cable', 'Motor']),
      authorizationDetails: 'Pending verification / No CPCB registration certificate',
      authorizationStatus: 'unverified',
      phone: '+91 9820099112',
      offeredRatesJson: JSON.stringify({ Cable: 210, Motor: 170 }),
      pickupAvailable: false,
      serviceAreaRadiusKm: 10.0,
      dataMaturity: 'synthetic'
    },
    {
      id: 'rec-012',
      name: 'Pragati Reclaimers (Application In Progress)',
      locationLat: 19.167,
      locationLng: 72.934,
      address: 'Bhandup Industrial Area, Mumbai 400078',
      materialsAccepted: JSON.stringify(['PCB', 'Battery']),
      authorizationDetails: 'Application No. MPCB-APP-2026-9081 - Inspection Pending',
      authorizationStatus: 'pending',
      phone: '+91 9821033445',
      offeredRatesJson: JSON.stringify({ PCB: 130, Battery: 80 }),
      pickupAvailable: true,
      serviceAreaRadiusKm: 20.0,
      dataMaturity: 'synthetic'
    }
  ];

  for (const r of recyclersData) {
    await prisma.recycler.create({ data: r });
  }
  console.log(`[Seed] Seeded ${recyclersData.length} recyclers.`);

  // 3. Seed Users (Demo Accounts)
  const demoCollector = await prisma.user.create({
    data: {
      id: 'user-collector-01',
      phone: '+91 9876543210',
      name: 'Ramesh Kumar (कबाड़ी)',
      role: 'collector',
      language: 'hi',
      dataMaturity: 'demo'
    }
  });

  const demoRecyclerUser = await prisma.user.create({
    data: {
      id: 'user-recycler-01',
      phone: '+91 9876543211',
      name: 'EcoMetals Yard Manager',
      role: 'recycler',
      language: 'en',
      recyclerId: 'rec-001',
      dataMaturity: 'demo'
    }
  });

  const demoAdminUser = await prisma.user.create({
    data: {
      id: 'user-admin-01',
      phone: '+91 9876543212',
      name: 'Dhatu Compliance Admin',
      role: 'admin',
      language: 'en',
      dataMaturity: 'demo'
    }
  });

  console.log('[Seed] Seeded demo accounts (Collector, Recycler, Admin).');

  // 4. Seed Price Records (35+ Price data points across categories and locations)
  const categories = ['PCB', 'Battery', 'Cable', 'CRT', 'Motor'];
  const locations = [
    { areaName: 'Dharavi Central Yard, Mumbai', lat: 19.0434, lng: 72.8567 },
    { areaName: 'Bhosari MIDC, Pune', lat: 18.627, lng: 73.847 },
    { areaName: 'Mayapuri Phase 1, New Delhi', lat: 28.629, lng: 77.126 },
    { areaName: 'Peenya Industrial, Bengaluru', lat: 13.031, lng: 77.525 },
    { areaName: 'Jeedimetla Estate, Hyderabad', lat: 17.516, lng: 78.471 }
  ];

  const baseRates: Record<string, number> = {
    PCB: 135,
    Battery: 85,
    Cable: 240,
    CRT: 35,
    Motor: 195
  };

  const now = Date.now();
  let priceRecordCount = 0;

  for (const cat of categories) {
    const base = baseRates[cat];
    for (const loc of locations) {
      // 3 historical points per category-location combination (spread over 30 days)
      for (let dayOffset of [0, 7, 18, 28]) {
        const date = new Date(now - dayOffset * 24 * 60 * 60 * 1000);
        const variance = (Math.random() * 8 - 4); // +/- 4 INR variation
        const price = Math.round((base + variance) * 10) / 10;

        await prisma.priceRecord.create({
          data: {
            materialCategory: cat,
            locationLat: loc.lat,
            locationLng: loc.lng,
            areaName: loc.areaName,
            dateTime: date,
            buyingPriceInr: price,
            quotedPriceInr: Math.round(price * 1.05),
            unit: 'per_kg',
            recyclerOrAggregatorId: 'rec-001',
            recyclerName: 'EcoMetals Green Yard',
            dataMaturity: 'synthetic'
          }
        });
        priceRecordCount++;
      }
    }
  }
  console.log(`[Seed] Seeded ${priceRecordCount} historical Price Records across 5 materials and 5 cities.`);

  // 5. Seed Sample Material Lots & Transactions across all lifecycle stages
  const sampleLots = [
    {
      lotId: 'DH-2026-0812',
      category: 'PCB',
      subCategory: 'Green FR-4 High-Grade Motherboard',
      weightKg: 14.5,
      condition: 'good',
      estMin: 1800,
      estMax: 2200,
      quoted: 2000,
      finalPrice: 2030,
      status: 'paid',
      paymentStatus: 'paid',
      paymentMethod: 'digital',
      recyclerId: 'rec-001',
      recyclerName: 'EcoMetals Green Yard Pvt Ltd',
      dataMaturity: 'demo',
      daysAgo: 4
    },
    {
      lotId: 'DH-2026-0815',
      category: 'Battery',
      subCategory: 'Lithium-Ion E-Bike Pack Cells',
      weightKg: 22.0,
      condition: 'good',
      estMin: 1800,
      estMax: 2100,
      quoted: 1950,
      finalPrice: 1980,
      status: 'recycler_confirmed',
      paymentStatus: 'pending',
      paymentMethod: 'digital',
      recyclerId: 'rec-002',
      recyclerName: 'Sahyadri E-Waste Recyclers',
      dataMaturity: 'demo',
      daysAgo: 2
    },
    {
      lotId: 'DH-2026-0818',
      category: 'Cable',
      subCategory: 'Heavy Copper Industrial Power Cables',
      weightKg: 35.0,
      condition: 'good',
      estMin: 8000,
      estMax: 9000,
      quoted: 8500,
      finalPrice: 8575,
      status: 'handed_over',
      paymentStatus: 'pending',
      recyclerId: 'rec-001',
      recyclerName: 'EcoMetals Green Yard Pvt Ltd',
      dataMaturity: 'demo',
      daysAgo: 1
    },
    {
      lotId: 'DH-2026-0820',
      category: 'Motor',
      subCategory: 'AC Fan & Pump Stator Coils',
      weightKg: 18.0,
      condition: 'good',
      estMin: 3200,
      estMax: 3800,
      quoted: 3600,
      finalPrice: 3600,
      status: 'offer_accepted',
      paymentStatus: 'pending',
      recyclerId: 'rec-003',
      recyclerName: 'Navi Mumbai Precious Metal Extraction',
      dataMaturity: 'demo',
      daysAgo: 0
    },
    {
      lotId: 'DH-2026-0822',
      category: 'CRT',
      subCategory: 'Heavy Old Television Cathode Tubes',
      weightKg: 40.0,
      condition: 'damaged',
      estMin: 1200,
      estMax: 1600,
      quoted: 1400,
      status: 'draft',
      paymentStatus: 'pending',
      dataMaturity: 'demo',
      daysAgo: 0
    },
    // Synthetic Lot with extreme rate to trigger Anomaly Flag (2-Sigma deviation test)
    {
      lotId: 'DH-2026-0899',
      category: 'PCB',
      subCategory: 'Gold-Plated Telecom Boards',
      weightKg: 10.0,
      condition: 'good',
      estMin: 1300,
      estMax: 1500,
      quoted: 1400,
      finalPrice: 4200, // ₹420/kg vs baseline ₹135/kg -> huge deviation!
      status: 'paid',
      paymentStatus: 'paid',
      paymentMethod: 'cash',
      recyclerId: 'rec-001',
      recyclerName: 'EcoMetals Green Yard Pvt Ltd',
      dataMaturity: 'synthetic',
      daysAgo: 3
    }
  ];

  for (const s of sampleLots) {
    const createdDate = new Date(now - s.daysAgo * 24 * 60 * 60 * 1000);

    const material = await prisma.material.create({
      data: {
        category: s.category,
        subCategory: s.subCategory,
        imageUrl: `/uploads/sample_${s.category.toLowerCase()}.jpg`,
        approxWeightKg: s.weightKg,
        condition: s.condition,
        sourceType: 'collector_pickup',
        estimatedValueMinInr: s.estMin,
        estimatedValueMaxInr: s.estMax,
        dataMaturity: s.dataMaturity
      }
    });

    // Build timeline reflecting exact stage
    const timeline = [
      {
        stage: 'Lot Created',
        timestamp: createdDate.toISOString(),
        note: `Digital lot registered with weight ${s.weightKg} kg.`,
        actorRole: 'collector'
      },
      {
        stage: 'Price Estimated',
        timestamp: new Date(createdDate.getTime() + 60000).toISOString(),
        note: `AI identified ${s.category}; estimated range ₹${s.estMin}–₹${s.estMax}.`,
        actorRole: 'system'
      }
    ];

    if (s.recyclerId) {
      timeline.push({
        stage: 'Recycler Matched',
        timestamp: new Date(createdDate.getTime() + 180000).toISOString(),
        note: `Matched with ${s.recyclerName}.`,
        actorRole: 'collector'
      });
    }

    if (['offer_accepted', 'handed_over', 'recycler_confirmed', 'paid'].includes(s.status)) {
      timeline.push({
        stage: 'Offer Accepted',
        timestamp: new Date(createdDate.getTime() + 360000).toISOString(),
        note: `Offer accepted at ₹${s.finalPrice || s.quoted}.`,
        actorRole: 'collector'
      });
    }

    if (['handed_over', 'recycler_confirmed', 'paid'].includes(s.status)) {
      timeline.push({
        stage: 'Material Handed Over',
        timestamp: new Date(createdDate.getTime() + 720000).toISOString(),
        note: `Physical handover completed. Ref: REF-${s.lotId.replace('DH-', '')}`,
        actorRole: 'collector'
      });
    }

    if (['recycler_confirmed', 'paid'].includes(s.status)) {
      timeline.push({
        stage: 'Recycler Confirmed',
        timestamp: new Date(createdDate.getTime() + 900000).toISOString(),
        note: 'Authorized yard verified weight and certified digital handover.',
        actorRole: 'recycler'
      });
    }

    if (s.status === 'paid') {
      timeline.push({
        stage: 'Payment Completed',
        timestamp: new Date(createdDate.getTime() + 1200000).toISOString(),
        note: `₹${s.finalPrice} settled via ${s.paymentMethod || 'digital'} transfer.`,
        actorRole: 'recycler'
      });
    }

    const tx = await prisma.transaction.create({
      data: {
        id: s.lotId,
        collectorId: demoCollector.id,
        collectorName: demoCollector.name,
        collectorPhone: demoCollector.phone,
        materialId: material.id,
        weightKg: s.weightKg,
        quotedPriceInr: s.quoted,
        finalPriceInr: s.finalPrice || undefined,
        recyclerId: s.recyclerId || undefined,
        recyclerName: s.recyclerName || undefined,
        collectionLat: 19.0434,
        collectionLng: 72.8567,
        collectionArea: 'Dharavi Sector 5 Collection Point',
        handoverLat: s.recyclerId ? 19.076 : undefined,
        handoverLng: s.recyclerId ? 72.8777 : undefined,
        handoverArea: s.recyclerId ? 'EcoMetals Main Facility' : undefined,
        dateTime: createdDate,
        paymentStatus: s.paymentStatus,
        paymentMethod: s.paymentMethod || undefined,
        transactionStatus: s.status,
        dataMaturity: s.dataMaturity
      }
    });

    await prisma.traceabilityRecord.create({
      data: {
        lotId: tx.id,
        photosJson: JSON.stringify([material.imageUrl]),
        weightKg: s.weightKg,
        gpsLat: 19.0434,
        gpsLng: 72.8567,
        gpsAddress: 'Dharavi Sector 5, Mumbai',
        handoverReferenceNumber: `REF-${s.lotId.replace('DH-', '')}`,
        recyclerConfirmation: ['recycler_confirmed', 'paid'].includes(s.status),
        timelineJson: JSON.stringify(timeline),
        dataMaturity: s.dataMaturity
      }
    });

    // If this is the synthetic high-rate lot DH-2026-0899, register the anomaly flag directly
    if (s.lotId === 'DH-2026-0899') {
      await prisma.anomalyFlag.create({
        data: {
          transactionId: tx.id,
          materialCategory: 'PCB',
          locationArea: 'Dharavi Central Yard, Mumbai',
          finalPriceInr: 420.0,
          expectedMeanPriceInr: 135.5,
          standardDeviationInr: 18.2,
          zScore: 15.63,
          severity: 'high',
          status: 'pending_review',
          details: 'Transaction rate ₹420/kg deviates +15.63 standard deviations from the 30-day baseline mean ₹135.5/kg. Flagged for review.',
          dataMaturity: 'synthetic'
        }
      });
      console.log('[Seed] Seeded statistical Anomaly Flag for DH-2026-0899 (>2 sigma deviation).');
    }
  }

  // 6. Audit Logs
  await prisma.auditLog.create({
    data: {
      userId: demoAdminUser.id,
      action: 'SYSTEM_INITIALIZATION_AND_SEED',
      targetEntity: 'Platform',
      targetId: 'dhatu-v1',
      details: 'Initial seed datasets loaded with 12 recyclers, 35+ price records, and sample lots.'
    }
  });

  console.log('[Seed] Database seeding completed successfully with full data integrity!');
}

main()
  .catch((e) => {
    console.error('[Seed Error]', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
