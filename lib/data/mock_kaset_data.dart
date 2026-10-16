const List<Map<String, dynamic>> mockCategories = [
  {
    'id': '2',
    'name': 'ปุ๋ยและเคมีภัณฑ์',
    'img': 'assets/images/kaset/category_fertilizer.png',
    'iconBgColor': 0xFFF4FAF3,
    'borderColor': 0xFFE0ECDD,
  },
  {
    'id': '4',
    'name': 'วัตถุดิบและอาหารสัตว์',
    'img': 'assets/images/kaset/category_feed.png',
    'iconBgColor': 0xFFF7F8EF,
    'borderColor': 0xFFE7EAD9,
  },
  {
    'id': '3',
    'name': 'เครื่องมือการเกษตร',
    'img': 'assets/images/kaset/category_tools.png',
    'iconBgColor': 0xFFF2F7F6,
    'borderColor': 0xFFDDEBE8,
  },
  {
    'id': '1',
    'name': 'เทคโนโลยีการเกษตร',
    'img': 'assets/images/kaset/dron.png',
    'iconBgColor': 0xFFF1F7F1,
    'borderColor': 0xFFDDE9DD,
  },
];

const Map<String, List<String>> mockSubcategoriesByType = {
  '1': [
    'โดรนเกษตร',
    'ระบบน้ำอัจฉริยะ',
    'เซนเซอร์และ IoT',
    'เครื่องจักรกลการเกษตร',
    'พลังงานและโรงเรือน',
  ],
  '2': [
    'ปุ๋ยอินทรีย์',
    'ปุ๋ยเคมี',
    'สารปรับปรุงดิน',
    'สารป้องกันพืช',
    'ธาตุอาหารเสริม',
  ],
  '3': [
    'เครื่องพ่นและฉีด',
    'เครื่องมือตัดแต่ง',
    'อุปกรณ์ให้น้ำ',
    'อุปกรณ์เก็บเกี่ยว',
    'เครื่องมือช่างเกษตร',
  ],
  '4': [
    'วัตถุดิบอาหารสัตว์',
    'อาหารสัตว์ปีก',
    'อาหารสุกร',
    'อาหารปลา',
    'อาหารโคและกระบือ',
  ],
};

const List<Map<String, dynamic>> mockProductList = [
  {
    'id': 4,
    'name': 'ปุ๋ยเคมีสูตร 15-15-15',
    'type': '2',
    'subcategory': 'ปุ๋ยเคมี',
    'price': 320.0,
    'description':
        'ปุ๋ยสูตรสมดุลสำหรับพืชไร่และพืชสวน ใช้บำรุงต้น เร่งการแตกใบ และเพิ่มความสมบูรณ์ของแปลงปลูก',
    'image':
        'https://www.chiataigroup.com/imgadmins/product_photo/pro20200602095323.png',
    'stock': 40,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 20,
    'name': 'ปุ๋ยยูเรียเม็ด 46-0-0',
    'type': '2',
    'subcategory': 'ปุ๋ยเคมี',
    'price': 280.0,
    'description':
        'ปุ๋ยไนโตรเจนสูง เหมาะสำหรับเร่งใบ เร่งต้น และการเตรียมแปลงปลูกช่วงเจริญเติบโต',
    'image':
        'https://www.chiataigroup.com/imgadmins/product_photo/pro20200602142425.png',
    'stock': 55,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 22,
    'name': 'ปุ๋ยอินทรีย์ชีวภาพอัดเม็ด',
    'type': '2',
    'subcategory': 'ปุ๋ยอินทรีย์',
    'price': 240.0,
    'description':
        'ปุ๋ยอินทรีย์ช่วยเพิ่มอินทรียวัตถุ ฟื้นฟูโครงสร้างดิน และเหมาะกับแนวทางเกษตรปลอดภัย',
    'image':
        'https://www.tpipolene.com/_next/image?url=https%3A%2F%2Fstorage.tpipolene.co.th%2Fproducts%2F1730701070916.png&w=3840&q=75',
    'stock': 28,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 23,
    'name': 'สารปรับสภาพดินโดโลไมท์',
    'type': '2',
    'subcategory': 'สารปรับปรุงดิน',
    'price': 190.0,
    'description':
        'ช่วยปรับค่าความเป็นกรดด่างของดิน เพิ่มประสิทธิภาพการดูดซึมธาตุอาหารก่อนเพาะปลูก',
    'image':
        'https://www.tpipolene.com/_next/image?url=https%3A%2F%2Fstorage.tpipolene.co.th%2Fproducts%2F1764658869770.png&w=3840&q=75',
    'stock': 20,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 21,
    'name': 'สารกำจัดเพลี้ยดูดกินชนิดน้ำ',
    'type': '2',
    'subcategory': 'สารป้องกันพืช',
    'price': 180.0,
    'description':
        'สารป้องกันกำจัดแมลงศัตรูพืชสำหรับเพลี้ยและแมลงดูดกิน ใช้งานสะดวกในแปลงพืชผัก',
    'image': 'https://inwfile.com/s-dy/3r5xxz.jpg',
    'stock': 38,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 24,
    'name': 'แคลเซียม-โบรอนเสริมทางใบ',
    'type': '2',
    'subcategory': 'ธาตุอาหารเสริม',
    'price': 260.0,
    'description':
        'ธาตุอาหารรองและเสริมสำหรับพืชสวน ช่วยลดอาการขาดธาตุและเพิ่มคุณภาพผลผลิต',
    'image':
        'https://www.tpipolene.com/_next/image?url=https%3A%2F%2Fstorage.tpipolene.co.th%2Fproducts%2F1766134302971.png&w=1920&q=75',
    'stock': 26,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 27,
    'name': 'สารจับใบสำหรับพ่นทางใบ',
    'type': '2',
    'subcategory': 'สารป้องกันพืช',
    'price': 145.0,
    'description':
        'ช่วยเพิ่มประสิทธิภาพการเกาะติดของสารพ่นทางใบ ลดการไหลทิ้ง และกระจายตัวสม่ำเสมอ',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQgQB6YTy16dwzVjxDwr7xoHQcj8mzvo1sARYPcD1LtpcD285QHHm6IU4Bw&s=10',
    'stock': 31,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 28,
    'name': 'ฮิวมิคบำรุงรากเข้มข้น',
    'type': '2',
    'subcategory': 'ธาตุอาหารเสริม',
    'price': 310.0,
    'description':
        'สารเสริมอินทรียวัตถุสำหรับระบบราก ช่วยให้พืชตั้งตัวดีและดูดซึมธาตุอาหารได้ดีขึ้น',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4wPW-1fatJvyxRAbcHlOJbm6fW3Rqyi64ixx4G0XyJy6SKTvLQocjSGo&s=10',
    'stock': 18,
    'shopName': 'ศูนย์ปุ๋ยและเคมีภัณฑ์',
  },
  {
    'id': 31,
    'name': 'ปลายข้าวสำหรับผสมอาหารสัตว์',
    'type': '4',
    'subcategory': 'วัตถุดิบอาหารสัตว์',
    'price': 210.0,
    'description':
        'วัตถุดิบพลังงานสำหรับผสมสูตรอาหารสัตว์ เหมาะกับฟาร์มที่ผลิตอาหารใช้เอง',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7SrdrAFNvXRLwd8-P6TnnZ0Hv3skLnwG4BtaLBdsoDA&s=10',
    'stock': 42,
    'shopName': 'ศูนย์วัตถุดิบและอาหารสัตว์',
  },
  {
    'id': 32,
    'name': 'กากถั่วเหลืองโปรตีนสูง',
    'type': '4',
    'subcategory': 'วัตถุดิบอาหารสัตว์',
    'price': 420.0,
    'description':
        'วัตถุดิบโปรตีนสูงสำหรับผสมอาหารสัตว์ ช่วยเพิ่มคุณค่าทางโภชนาการในสูตรฟาร์ม',
    'image':
        'https://img.lazcdn.com/g/ff/kf/S3ee7b13e57a6441ebfb39af33044e718d.jpg_720x720q80.jpg',
    'stock': 24,
    'shopName': 'ศูนย์วัตถุดิบและอาหารสัตว์',
  },
  {
    'id': 33,
    'name': 'อาหารไก่เนื้อระยะโต',
    'type': '4',
    'subcategory': 'อาหารสัตว์ปีก',
    'price': 250.0,
    'description':
        'อาหารไก่เนื้อสูตรมาตรฐาน โปรตีนเหมาะสม ช่วยการเจริญเติบโตสม่ำเสมอ',
    'image': 'https://inwfile.com/s-ca/8rdjl3.jpg',
    'stock': 30,
    'shopName': 'ศูนย์วัตถุดิบและอาหารสัตว์',
  },
  {
    'id': 34,
    'name': 'อาหารสุกรรุ่นกลาง',
    'type': '4',
    'subcategory': 'อาหารสุกร',
    'price': 300.0,
    'description':
        'อาหารสำหรับสุกรช่วงขุน ช่วยเสริมการเจริญเติบโตและการย่อยอาหารในระบบฟาร์ม',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT14XRzemKcuD6SB0AVJaw0iT35o0TNAjjsmz3LX_BQ9m0ChHo2RXWJsa8&s=10',
    'stock': 24,
    'shopName': 'ศูนย์วัตถุดิบและอาหารสัตว์',
  },
  {
    'id': 35,
    'name': 'อาหารปลานิลเม็ดลอย',
    'type': '4',
    'subcategory': 'อาหารปลา',
    'price': 220.0,
    'description':
        'อาหารเม็ดสำหรับปลา เน้นการโตไว ควบคุมการให้อาหารง่าย และช่วยดูแลคุณภาพน้ำในบ่อ',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRaL6edY1jhLSByav8EqLdTFDGH_ywYpdFj9C5pRaF0tg&s=10',
    'stock': 35,
    'shopName': 'ศูนย์วัตถุดิบและอาหารสัตว์',
  },
  {
    'id': 36,
    'name': 'อาหารโคขุนเสริมพลังงาน',
    'type': '4',
    'subcategory': 'อาหารโคและกระบือ',
    'price': 400.0,
    'description':
        'อาหารสัตว์สำหรับโคเนื้อและกระบือ ช่วยเสริมพลังงานและโปรตีนเพื่อการขุนคุณภาพ',
    'image':
        'https://down-th.img.susercontent.com/file/th-11134207-81zto-mhg29w2kdxq86f.webp',
    'stock': 18,
    'shopName': 'ศูนย์วัตถุดิบและอาหารสัตว์',
  },
  {
    'id': 38,
    'name': 'รำละเอียดคัดสะอาด',
    'type': '4',
    'subcategory': 'วัตถุดิบอาหารสัตว์',
    'price': 60.0,
    'description':
        'วัตถุดิบพื้นฐานสำหรับผสมอาหารสัตว์ เหมาะกับฟาร์มขนาดเล็กและกลุ่มเกษตรกรผู้เลี้ยงสัตว์',
    'image':
        'https://down-th.img.susercontent.com/file/th-11134207-7rase-m8xj1to590jt4b',
    'stock': 44,
    'shopName': 'ศูนย์วัตถุดิบและอาหารสัตว์',
  },
  {
    'id': 2,
    'name': 'เครื่องพ่นยาแบตเตอรี่ 20 ลิตร',
    'type': '3',
    'subcategory': 'เครื่องพ่นและฉีด',
    'price': 890.0,
    'description':
        'เครื่องพ่นสารแบบสะพายหลัง ใช้งานคล่องตัว เหมาะกับงานสวน แปลงผัก และการดูแลแปลงเพาะปลูก',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQuhPvBilwhJY1F4EGj--fG29vEVDW7YJNuPFKnMXKUUw&s=10',
    'stock': 14,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 18,
    'name': 'ถังพ่นแรงดันสะพายหลัง',
    'type': '3',
    'subcategory': 'เครื่องพ่นและฉีด',
    'price': 320.0,
    'description':
        'อุปกรณ์พ่นน้ำและปุ๋ยแบบแรงดัน ใช้งานต่อเนื่องดี น้ำหนักเบา และพกพาสะดวก',
    'image': 'https://inwfile.com/s-cm/c7n8gn.png',
    'stock': 22,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 10,
    'name': 'กรรไกรตัดแต่งกิ่งสแตนเลส',
    'type': '3',
    'subcategory': 'เครื่องมือตัดแต่ง',
    'price': 150.0,
    'description':
        'กรรไกรตัดกิ่งคม ทนทาน เหมาะสำหรับงานสวน งานแต่งทรง และการตัดแต่งผลผลิต',
    'image':
        'https://backoffice.itoolmart.com/assets/images/uploads/product/md/md_product_1632715495.jpg',
    'stock': 48,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 19,
    'name': 'สายยางรดน้ำ 20 เมตร',
    'type': '3',
    'subcategory': 'อุปกรณ์ให้น้ำ',
    'price': 350.0,
    'description':
        'สายยางคุณภาพสูง เหมาะกับแปลงผัก โรงเรือน และงานให้น้ำพื้นที่ขนาดเล็กถึงกลาง',
    'image': 'https://ktoolmart.co.th/wp-content/uploads/2825149185825_0-4.jpg',
    'stock': 30,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 25,
    'name': 'รถเข็นลำเลียงผลผลิตเหล็กชุบ',
    'type': '3',
    'subcategory': 'อุปกรณ์เก็บเกี่ยว',
    'price': 1690.0,
    'description':
        'รถเข็นสำหรับลำเลียงผลผลิต ปุ๋ย หรืออุปกรณ์ภายในฟาร์ม โครงสร้างแข็งแรงใช้งานทนทาน',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ7hMRFJU-Q2CLYKI_kA2JrRKCNcdiq3x0g9-m8N-UwW1HcY6izil1kUOs&s=10',
    'stock': 12,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 26,
    'name': 'ชุดประแจซ่อมบำรุงเครื่องจักร',
    'type': '3',
    'subcategory': 'เครื่องมือช่างเกษตร',
    'price': 690.0,
    'description':
        'ชุดเครื่องมือพื้นฐานสำหรับซ่อมบำรุงปั๊มน้ำ รถไถ และเครื่องจักรกลภายในฟาร์ม',
    'image':
        'https://th.misumi-ec.com/th/linked/material/fs/BQQ1/PHOTO/223302153449_001.jpg',
    'stock': 16,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 39,
    'name': 'พลั่วขุดดินด้ามไฟเบอร์',
    'type': '3',
    'subcategory': 'เครื่องมือช่างเกษตร',
    'price': 420.0,
    'description':
        'เครื่องมือพื้นฐานสำหรับงานฟาร์มและแปลงปลูก ด้ามจับแข็งแรง น้ำหนักสมดุล ใช้งานได้นาน',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSqWmrxrxr0HzjlWqIv9AequiEvSY94wEjfmNIoC-53M-mt4m3_2ZPrK2k&s=10',
    'stock': 37,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 40,
    'name': 'รถพรวนดินขนาดเล็กแบบเข็น',
    'type': '3',
    'subcategory': 'อุปกรณ์เก็บเกี่ยว',
    'price': 6850.0,
    'description':
        'อุปกรณ์ช่วยพรวนและจัดหน้าดินสำหรับแปลงผักขนาดย่อม เหมาะกับงานเกษตรชุมชนและโรงเรือน',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTPLc1XTBg3FNrFGKY8nbpI_TrpiEd5OwCI05gJA37F90ddRUJY3W1_K4c&s=10',
    'stock': 5,
    'shopName': 'ศูนย์เครื่องมือการเกษตร',
  },
  {
    'id': 1,
    'name': 'โดรนพ่นสารเกษตร 10 ลิตร',
    'type': '1',
    'subcategory': 'โดรนเกษตร',
    'price': 89500.0,
    'description':
        'โดรนสำหรับพ่นสารและปุ๋ยน้ำ ช่วยลดเวลาในการทำงานและเพิ่มความสม่ำเสมอในการกระจายสาร',
    'image':
        'https://www.famadrone.com/wp-content/uploads/2021/06/%E0%B8%82%E0%B8%B2%E0%B8%A2%E0%B9%82%E0%B8%94%E0%B8%A3%E0%B8%99%E0%B9%80%E0%B8%81%E0%B8%A9%E0%B8%95%E0%B8%A3-DJI-T10-1.jpg',
    'stock': 4,
    'shopName': 'ศูนย์เทคโนโลยีการเกษตร',
  },
  {
    'id': 6,
    'name': 'สวิทซ์อัตโนมัติควบคุมปั้มน้ำ',
    'type': '1',
    'subcategory': 'ระบบน้ำอัจฉริยะ',
    'price': 1250.0,
    'description':
        'ระบบตั้งเวลาและควบคุมปั๊มน้ำอัตโนมัติสำหรับแปลงเกษตรและโรงเรือน',
    'image':
        'https://media.tarad.com/w/water-mart/img-lib/spd_20130911121544_b.jpg',
    'stock': 9,
    'shopName': 'ศูนย์เทคโนโลยีการเกษตร',
  },
  {
    'id': 12,
    'name': 'เซนเซอร์วัดความชื้นดิน',
    'type': '1',
    'subcategory': 'เซนเซอร์และ IoT',
    'price': 1850.0,
    'description':
        'อุปกรณ์ตรวจวัดความชื้นดินแบบดิจิทัล เหมาะกับการติดตามข้อมูลและจัดการให้น้ำอย่างแม่นยำ',
    'image': 'https://i.ebayimg.com/images/g/aYMAAeSwrcVphT3~/s-l1600.webp',
    'stock': 25,
    'shopName': 'ศูนย์เทคโนโลยีการเกษตร',
  },
  {
    'id': 13,
    'name': 'รถไถเดินตามพร้อมผานพรวน',
    'type': '1',
    'subcategory': 'เครื่องจักรกลการเกษตร',
    'price': 45900.0,
    'description':
        'เครื่องจักรกลสำหรับเตรียมแปลงและพรวนดิน เหมาะกับพื้นที่เกษตรขนาดเล็กถึงกลาง',
    'image':
        'https://s.alicdn.com/@sc04/kf/He0ad69784c9e43138f92a802bd52e597O.jpg_300x300.jpg',
    'stock': 3,
    'shopName': 'ศูนย์เทคโนโลยีการเกษตร',
  },
  {
    'id': 14,
    'name': 'แผงโซลาร์เซลล์สำหรับปั๊มน้ำเกษตร',
    'type': '1',
    'subcategory': 'พลังงานและโรงเรือน',
    'price': 2569.0,
    'description':
        'ระบบพลังงานแสงอาทิตย์สำหรับงานสูบน้ำในฟาร์ม ช่วยลดต้นทุนค่าไฟฟ้าระยะยาว',
    'image':
        'https://s.alicdn.com/@sc04/kf/H4714775d01e24d7c92c44effb0c86deeD.png_300x300.jpg',
    'stock': 7,
    'shopName': 'ศูนย์เทคโนโลยีการเกษตร',
  },
  {
    'id': 41,
    'name': 'ชุดกล้องตรวจแปลงพร้อมแอป',
    'type': '1',
    'subcategory': 'เซนเซอร์และ IoT',
    'price': 6650.0,
    'description':
        'ระบบกล้องตรวจแปลงสำหรับติดตามสภาพพื้นที่และดูภาพผ่านแอป เหมาะกับแปลงทดลองและฟาร์มสมัยใหม่',
    'image':
        'https://www.abshop.in.th/web/image/product.product/33018/image_1024/%5BDH-0651%5D%20DAHUA%20DH-IPC-PTS2649C-3E3Z-4GB20%20%E0%B8%81%E0%B8%A5%E0%B9%89%E0%B8%AD%E0%B8%87%E0%B8%A7%E0%B8%87%E0%B8%88%E0%B8%A3%E0%B8%9B%E0%B8%B4%E0%B8%94%204G%20%E0%B9%81%E0%B8%9A%E0%B8%95%E0%B9%80%E0%B8%95%E0%B8%AD%E0%B8%A3%E0%B8%B5%E0%B9%88%E0%B9%82%E0%B8%8B%E0%B8%A5%E0%B9%88%E0%B8%B2%E0%B9%80%E0%B8%8B%E0%B8%A5%206%20%E0%B8%A5%E0%B9%89%E0%B8%B2%E0%B8%99%E0%B8%9E%E0%B8%B4%E0%B8%81%E0%B9%80%E0%B8%8B%E0%B8%A5%20%283MP%2B3MP%29%28Dual%20Lens%29?unique=d4f7c7b',
    'stock': 11,
    'shopName': 'ศูนย์เทคโนโลยีการเกษตร',
  },
  {
    'id': 42,
    'name': 'เครื่องชาร์จแบตเตอรี่โดรนภาคสนาม',
    'type': '1',
    'subcategory': 'โดรนเกษตร',
    'price': 29000.0,
    'description':
        'อุปกรณ์เสริมสำหรับงานโดรนเกษตร ช่วยชาร์จแบตเตอรี่หน้างานและลดเวลาหยุดปฏิบัติงาน',
    'image':
        'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQerDOcy7NVxOyJIKSLAYeat7iZKEIaEPP6zLfgeLH7Wu4E3iM4VKILqZ5y&s=10',
    'stock': 13,
    'shopName': 'ศูนย์เทคโนโลยีการเกษตร',
  },
];

const Map<int, int> mockProductInterestScoreById = {
  1: 98,
  2: 85,
  4: 88,
  6: 84,
  10: 79,
  12: 83,
  13: 95,
  14: 76,
  15: 81,
  18: 74,
  19: 72,
  20: 82,
  21: 73,
  22: 90,
  23: 71,
  24: 68,
  25: 77,
  26: 66,
  27: 64,
  28: 75,
  31: 70,
  32: 89,
  33: 80,
  34: 74,
  35: 86,
  36: 78,
  37: 69,
  38: 67,
  39: 65,
  40: 87,
  41: 85,
  42: 79,
};

const Map<int, int> mockProductSoldCountById = {
  1: 12,
  2: 27,
  4: 44,
  6: 18,
  10: 33,
  12: 22,
  13: 16,
  14: 11,
  15: 14,
  18: 25,
  19: 19,
  20: 41,
  21: 28,
  22: 39,
  23: 20,
  24: 17,
  25: 13,
  26: 10,
  27: 15,
  28: 21,
  31: 26,
  32: 35,
  33: 31,
  34: 23,
  35: 37,
  36: 18,
  37: 16,
  38: 29,
  39: 22,
  40: 14,
  41: 20,
  42: 19,
};

String mockCategoryTitle(String type) {
  final category = mockCategories.cast<Map<String, dynamic>?>().firstWhere(
        (item) => item?['id'] == type,
        orElse: () => null,
      );
  return category?['name']?.toString() ?? 'สินค้า';
}

List<String> mockSubcategoriesForType(String type) {
  final subcategories = mockSubcategoriesByType[type] ?? const <String>[];
  return <String>['ทั้งหมด', ...subcategories];
}

List<Map<String, dynamic>> mockBestSellerProducts({int limit = 6}) {
  final rankedProducts = mockProductList.map((item) {
    final product = Map<String, dynamic>.from(item);
    final id = product['id'] as int? ?? 0;
    final interestScore = mockProductInterestScoreById[id] ?? 60;
    final soldCount = mockProductSoldCountById[id] ?? 12;
    final bestSellerScore =
        ((interestScore * 0.65) + (soldCount * 0.35)).round();

    product['interestScore'] = interestScore;
    product['soldCount'] = soldCount;
    product['bestSellerScore'] = bestSellerScore;
    return product;
  }).toList()
    ..sort((a, b) {
      final scoreCompare =
          (b['bestSellerScore'] as int).compareTo(a['bestSellerScore'] as int);
      if (scoreCompare != 0) return scoreCompare;
      return (b['interestScore'] as int).compareTo(a['interestScore'] as int);
    });

  final selected = <Map<String, dynamic>>[];
  final selectedIds = <int>{};
  final coveredTypes = <String>{};

  for (final product in rankedProducts) {
    final type = product['type']?.toString() ?? '';
    final id = product['id'] as int? ?? 0;
    if (coveredTypes.contains(type)) continue;
    coveredTypes.add(type);
    selected.add(product);
    selectedIds.add(id);
    if (selected.length >= limit) {
      return selected;
    }
  }

  for (final product in rankedProducts) {
    final id = product['id'] as int? ?? 0;
    if (selectedIds.contains(id)) continue;
    selected.add(product);
    selectedIds.add(id);
    if (selected.length >= limit) {
      break;
    }
  }

  return selected.take(limit).toList();
}
