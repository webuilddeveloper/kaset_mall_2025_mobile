const List<Map<String, dynamic>> mockCategories = [
  {
    'id': '1',
    'name': 'สินค้าเกษตร',
    'img': 'assets/images/kaset/category_basket.png',
  },
  {
    'id': '2',
    'name': 'ปุ๋ยเคมีภัณฑ์',
    'img': 'assets/images/kaset/category_fertilizer.png',
  },
  {
    'id': '3',
    'name': 'เครื่องมือ',
    'img': 'assets/images/kaset/category_tools.png',
  },
  {
    'id': '4',
    'name': 'อาหารสัตว์',
    'img': 'assets/images/kaset/category_feed.png',
  },
];

const List<Map<String, dynamic>> mockProductList = [
  // ข้าวและธัญพืช
  {
    'id': 1,
    'name': 'ข้าวหอมมะลิใหม่ 100%',
    'type': '1',
    'price': 65.0,
    'description':
        'ข้าวหอมมะลิคัดพิเศษ กลิ่นหอม นุ่ม เหมาะสำหรับครัวเรือนและร้านอาหาร',
    'image':
        'https://down-th.img.susercontent.com/file/sg-11134201-824hj-mf0ukji0d2xacd@resize_w900_nl.webp',
    'stock': 120,
  },
  {
    'id': 6,
    'name': 'ข้าวเหนียวเขี้ยวงู',
    'type': '1',
    'price': 55.0,
    'description':
        'ข้าวเหนียวคุณภาพดี เหมาะกับเมนูท้องถิ่น ข้าวหลาม และของหวานไทย',
    'image':
        'https://down-th.img.susercontent.com/file/th-11134207-7ra0h-mbt7d5te73v781@resize_w900_nl.webp',
    'stock': 95,
  },
  {
    'id': 12,
    'name': 'ข้าวกล้องหอมมะลิ',
    'type': '1',
    'price': 75.0,
    'description': 'ข้าวกล้องคุณภาพดี กลิ่นหอมตามธรรมชาติ เหมาะกับสายสุขภาพ',
    'image': 'https://cw.lnwfile.com/_/cw/_raw/1e/gj/pa.jpg',
    'stock': 70,
  },
  {
    'id': 13,
    'name': 'ข้าวไรซ์เบอร์รี่',
    'type': '1',
    'price': 85.0,
    'description':
        'ข้าวสีม่วงเข้ม รสสัมผัสดี มีคุณค่าทางอาหาร เหมาะสำหรับครัวเรือนและร้านสุขภาพ',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQtz2JBb8ghgg8jzjTqmpWk7dRhQlalhWMQBvo0BQpHPvrYvFm1kCIqo_8&s=10',
    'stock': 50,
  },
  {
    'id': 14,
    'name': 'ข้าวโพดหวานคัดฝัก',
    'type': '1',
    'price': 35.0,
    'description': 'ข้าวโพดหวานสดใหม่ หวานกรอบ เหมาะสำหรับขายหน้าร้านและแปรรูป',
    'image':
        'https://bangkokfreshlink.com/cdn/shop/files/Sweet_Corn_Half_Husked_3_Ears_per_Pack_Per_kg.webp?v=1765273085&width=1214',
    'stock': 85,
  },

  // ผลไม้
  {
    'id': 7,
    'name': 'ส้มเขียวหวาน เบอร์ 5',
    'type': '1',
    'price': 80.0,
    'description':
        'ส้มคัดขนาดกำลังดี รสหวานอมเปรี้ยว สดใหม่จากแหล่งผลิตตามฤดูกาล',
    'image':
        'https://bangkokfreshlink.com/cdn/shop/files/Tangerine_Size_0_Per_kg.webp?v=1765273145&width=1214',
    'stock': 60,
  },
  {
    'id': 8,
    'name': 'มะนาวแป้นคัดพิเศษ',
    'type': '1',
    'price': 65.0,
    'description':
        'มะนาวลูกใหญ่ น้ำเยอะ เหมาะสำหรับร้านอาหารและการใช้งานในครัวเรือน',
    'image':
        'https://images.mango-prod.siammakro.cloud/product-images/6976617971907-d17876e4-a7fc-4a45-a336-5005d5eeb49a.jpeg?eo-img.resize=w%2F1080&eo-img.format=webp',
    'stock': 80,
  },
  {
    'id': 9,
    'name': 'สับปะรดภูแล',
    'type': '1',
    'price': 50.0,
    'description':
        'สับปะรดเนื้อหวาน กลิ่นหอม เหมาะเป็นผลไม้สดหรือแปรรูปเป็นของฝาก',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0XoqFewX77d7NrTBjx26l1pkE0E4rp6Hd2lmfvFaOvjxL4_yJWG02XDoe&s=10',
    'stock': 75,
  },
  {
    'id': 11,
    'name': 'มังคุดใต้คัดเกรด',
    'type': '1',
    'price': 100.0,
    'description':
        'มังคุดผลใหญ่ เปลือกสวย เนื้อหวานฉ่ำ เหมาะกับตลาดผลไม้พรีเมียม',
    'image':
        'https://down-th.img.susercontent.com/file/th-11134207-7qul2-lkddgi7s5bs978@resize_w900_nl.webp',
    'stock': 40,
  },

  // ผักและสมุนไพร
  {
    'id': 15,
    'name': 'ผักคะน้าก้านเขียว',
    'type': '1',
    'price': 25.0,
    'description': 'ผักคะน้าสดใหม่ ก้านกรอบ เหมาะกับร้านอาหารและครัวเรือน',
    'image':
        'https://www.clinicneo.com/wp-content/uploads/2021/05/-4.jpg-4.jpg',
    'stock': 90,
  },
  {
    'id': 16,
    'name': 'โหระพาสดตัดใหม่',
    'type': '1',
    'price': 18.0,
    'description': 'โหระพาคัดใบสด เหมาะสำหรับเมนูแกงและอาหารไทยทั่วไป',
    'image':
        'https://spfresh.co.th/wp-content/uploads/2022/12/%E0%B9%83%E0%B8%9A%E0%B9%82%E0%B8%AB%E0%B8%A3%E0%B8%B0%E0%B8%9E%E0%B8%B2-1.jpg',
    'stock': 110,
  },
  {
    'id': 17,
    'name': 'ตะไคร้คุณภาพคัดพิเศษ',
    'type': '1',
    'price': 22.0,
    'description': 'ตะไคร้สดกลิ่นหอม เหมาะกับครัวเรือน ร้านอาหาร และเครื่องแกง',
    'image':
        'https://res.cloudinary.com/freshketimage001/image/upload/c_fit,w_800,h_800,q_auto,f_auto/ziaiuiydrfddbirhljfh',
    'stock': 100,
  },

  // เครื่องมือการเกษตร
  {
    'id': 2,
    'name': 'เครื่องพ่นยาแบตเตอรี่ 20 ลิตร',
    'type': '3',
    'price': 890.0,
    'description':
        'เครื่องพ่นสารแบบพกพา ใช้งานง่าย เหมาะกับสวนผัก สวนผลไม้ และแปลงเกษตร',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQuhPvBilwhJY1F4EGj--fG29vEVDW7YJNuPFKnMXKUUw&s=10',
    'stock': 14,
  },
  {
    'id': 10,
    'name': 'กรรไกรตัดแต่งกิ่งสแตนเลส',
    'type': '3',
    'price': 150.0,
    'description':
        'กรรไกรตัดกิ่งคม ทนทาน เหมาะสำหรับงานสวน งานแต่งทรง และตัดแต่งผลไม้',
    'image':
        'https://backoffice.itoolmart.com/assets/images/uploads/product/md/md_product_1632715495.jpg',
    'stock': 48,
  },
  {
    'id': 29,
    'name': 'เครื่องตัดหญ้าไฟฟ้า',
    'type': '3',
    'price': 2500.0,
    'description':
        'เครื่องตัดหญ้ากำลังดี เหมาะกับพื้นที่บ้าน สวนขนาดเล็ก และแปลงเกษตร',
    'image':
        'https://www.yucmachinery.com/wp-content/uploads/2017/05/UR3000.jpg',
    'stock': 6,
  },
  {
    'id': 18,
    'name': 'ถังพ่นแรงดันสะพายหลัง',
    'type': '3',
    'price': 320.0,
    'description':
        'อุปกรณ์พ่นน้ำและปุ๋ย ใช้งานต่อเนื่องได้ดี น้ำหนักเบา พกพาสะดวก',
    'image': 'https://inwfile.com/s-cm/c7n8gn.png',
    'stock': 22,
  },
  {
    'id': 19,
    'name': 'สายยางรดน้ำ 20 เมตร',
    'type': '3',
    'price': 350.0,
    'description': 'สายยางคุณภาพสูง เหมาะกับสวนผักและแปลงเกษตรขนาดเล็กถึงกลาง',
    'image': 'https://ktoolmart.co.th/wp-content/uploads/2825149185825_0-4.jpg',
    'stock': 30,
  },

  // อาหารสัตว์
  {
    'id': 31,
    'name': 'อาหารไก่เนื้อเบอร์ 910',
    'type': '4',
    'price': 250.0,
    'description':
        'อาหารไก่เนื้อสูตรมาตรฐาน โปรตีนเหมาะสม ช่วยการเจริญเติบโตสม่ำเสมอ',
    'image': 'https://inwfile.com/s-ca/8rdjl3.jpg',
    'stock': 30,
  },
  {
    'id': 32,
    'name': 'อาหารหมูลูกพันธุ์ 101',
    'type': '4',
    'price': 300.0,
    'description': 'อาหารสำหรับลูกสุกร ช่วยเสริมการเจริญเติบโตและการย่อยอาหาร',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT14XRzemKcuD6SB0AVJaw0iT35o0TNAjjsmz3LX_BQ9m0ChHo2RXWJsa8&s=10',
    'stock': 24,
  },
  {
    'id': 33,
    'name': 'อาหารปลานิล',
    'type': '4',
    'price': 220.0,
    'description': 'อาหารเม็ดสำหรับปลา เน้นการโตไวและดูแลคุณภาพน้ำในบ่อเลี้ยง',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaL6edY1jhLSByav8EqLdTFDGH_ywYpdFj9C5pRaF0tg&s=10',
    'stock': 35,
  },
  {
    'id': 34,
    'name': 'อาหารวัว',
    'type': '4',
    'price': 400.0,
    'description': 'อาหารสัตว์สำหรับโคเนื้อและโคนม ช่วยเสริมพลังงานและโปรตีน',
    'image':
        'https://down-th.img.susercontent.com/file/th-11134207-81zto-mhg29w2kdxq86f.webp',
    'stock': 18,
  },
  {
    'id': 35,
    'name': 'อาหารไก่ไข่เบอร์ 926',
    'type': '4',
    'price': 280.0,
    'description':
        'อาหารไก่ไข่สูตรครบถ้วน เสริมแคลเซียมและโปรตีนสำหรับการให้ไข่',
    'image': 'https://inwfile.com/s-ca/36cdhf.jpg',
    'stock': 28,
  },

  // ปุ๋ยและเคมีภัณฑ์
  {
    'id': 4,
    'name': 'ปุ๋ยเคมีสูตร 15-15-15',
    'type': '2',
    'price': 320.0,
    'description':
        'ปุ๋ยสูตรสมดุล เหมาะสำหรับบำรุงพืชผัก ผลไม้ และพืชไร่หลากชนิด',
    'image':
        'https://www.chiataigroup.com/imgadmins/product_photo/pro20200602095323.png',
    'stock': 40,
  },
  {
    'id': 20,
    'name': 'ปุ๋ยยูเรียเม็ด',
    'type': '2',
    'price': 280.0,
    'description': 'ปุ๋ยไนโตรเจนสูง ช่วยเร่งการเจริญเติบโตของใบและลำต้น',
    'image':
        'https://www.chiataigroup.com/imgadmins/product_photo/pro20200602142425.png',
    'stock': 55,
  },
  {
    'id': 21,
    'name': 'ยาฆ่าแมลงกำจัดเพลี้ย',
    'type': '2',
    'price': 180.0,
    'description': 'สารป้องกันกำจัดศัตรูพืชสำหรับเพลี้ยและแมลงศัตรูในแปลงปลูก',
    'image': 'https://inwfile.com/s-dy/3r5xxz.jpg',
    'stock': 38,
  },
  {
    'id': 22,
    'name': 'ปุ๋ยอินทรีย์ชีวภาพ',
    'type': '2',
    'price': 240.0,
    'description':
        'ปุ๋ยอินทรีย์ช่วยฟื้นฟูดิน เพิ่มความร่วนซุย เหมาะกับเกษตรปลอดภัย',
    'image':
        'https://www.tpipolene.com/_next/image?url=https%3A%2F%2Fstorage.tpipolene.co.th%2Fproducts%2F1730701070916.png&w=3840&q=75',
    'stock': 28,
  },
  {
    'id': 23,
    'name': 'สารปรับสภาพดิน',
    'type': '2',
    'price': 190.0,
    'description':
        'ช่วยปรับสมดุลดินก่อนเพาะปลูก เพิ่มประสิทธิภาพการดูดซึมธาตุอาหาร',
    'image':
        'https://www.tpipolene.com/_next/image?url=https%3A%2F%2Fstorage.tpipolene.co.th%2Fproducts%2F1764658869770.png&w=3840&q=75',
    'stock': 20,
  },
];
