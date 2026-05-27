-- ============================================
-- DEN DA SIGNATURE DATABASE SEED DATA
-- ============================================

-- ============================================
-- 1. CATEGORIES
-- ============================================

-- Nếu bảng Categories có thêm Description
-- thì dùng đoạn này

INSERT INTO Categories (Name, Description)
VALUES
(N'Cà Phê', N'Các món cà phê truyền thống và pha máy'),
(N'Trà Trái Cây', N'Trà kết hợp trái cây tươi mát'),
(N'Đá Xay', N'Thức uống xay lạnh'),
(N'Trà Sữa', N'Trà sữa đậm vị'),
(N'Bánh Ngọt', N'Bánh ăn kèm thức uống');



-- ============================================
-- 2. OPTIONS
-- ============================================

INSERT INTO Options (Name, Type, AdditionalPrice)
VALUES
-- SIZE
(N'Size S', 'Size', 0),
(N'Size M', 'Size', 5000),
(N'Size L', 'Size', 10000),

-- ĐƯỜNG
(N'100% Đường', 'Sugar', 0),
(N'70% Đường', 'Sugar', 0),
(N'50% Đường', 'Sugar', 0),
(N'30% Đường', 'Sugar', 0),
(N'Không Đường', 'Sugar', 0),

-- ĐÁ
(N'100% Đá', 'Ice', 0),
(N'70% Đá', 'Ice', 0),
(N'Ít Đá', 'Ice', 0),
(N'Không Đá', 'Ice', 0),

-- TOPPING
(N'Trân châu trắng', 'Topping', 8000),
(N'Thạch sương sáo', 'Topping', 8000),
(N'Kem phô mai', 'Topping', 15000),
(N'Kem vanilla', 'Topping', 12000),
(N'Espresso Shot', 'Topping', 10000);



-- ============================================
-- 3. PRODUCTS
-- ============================================

-- CATEGORY ID:
-- 1 = Cà Phê
-- 2 = Trà Trái Cây
-- 3 = Đá Xay
-- 4 = Trà Sữa
-- 5 = Bánh Ngọt

INSERT INTO Products
(Name, BasePrice, ImageUrl, CategoryId, IsAvailable)
VALUES

-- =========================
-- CÀ PHÊ
-- =========================

(N'Cà Phê Đen Đá',
29000,
'https://images.unsplash.com/photo-1517701604599-bb29b565090c',
1,
1),

(N'Cà Phê Sữa Đá',
35000,
'https://images.unsplash.com/photo-1509042239860-f550ce710b93',
1,
1),

(N'Bạc Xỉu',
39000,
'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085',
1,
1),

(N'Cappuccino',
49000,
'https://images.unsplash.com/photo-1461023058943-07fcbe16d735',
1,
1),

(N'Latte',
52000,
'https://images.unsplash.com/photo-1523942839745-7848d53b04a9',
1,
1),

(N'Americano',
45000,
'https://images.unsplash.com/photo-1494314671902-399b18174975',
1,
1),


-- =========================
-- TRÀ TRÁI CÂY
-- =========================

(N'Trà Đào Cam Sả',
49000,
'https://images.unsplash.com/photo-1499636136210-6f4ee915583e',
2,
1),

(N'Trà Vải',
45000,
'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd',
2,
1),

(N'Trà Chanh',
29000,
'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd',
2,
1),

(N'Trà Dâu',
52000,
'https://images.unsplash.com/photo-1513639776629-7b61b0ac49cb',
2,
1),

(N'Trà Xoài',
52000,
'https://images.unsplash.com/photo-1623065422902-30a2d299bbe4',
2,
1),


-- =========================
-- ĐÁ XAY
-- =========================

(N'Cookie Đá Xay',
59000,
'https://images.unsplash.com/photo-1572490122747-3968b75cc699',
3,
1),

(N'Matcha Đá Xay',
62000,
'https://images.unsplash.com/photo-1515823064-d6e0c04616a7',
3,
1),

(N'Mocha Đá Xay',
65000,
'https://images.unsplash.com/photo-1579888944880-d98341245702',
3,
1),

(N'Socola Đá Xay',
58000,
'https://images.unsplash.com/photo-1517701604599-bb29b565090c',
3,
1),


-- =========================
-- TRÀ SỮA
-- =========================

(N'Trà Sữa Trân Châu',
49000,
'https://images.unsplash.com/photo-1558857563-b371033873b8',
4,
1),

(N'Trà Sữa Matcha',
55000,
'https://images.unsplash.com/photo-1558857563-b371033873b8',
4,
1),

(N'Trà Sữa Oolong',
52000,
'https://images.unsplash.com/photo-1525385133512-2f3bdd039054',
4,
1),


-- =========================
-- BÁNH NGỌT
-- =========================

(N'Tiramisu',
39000,
'https://images.unsplash.com/photo-1578985545062-69928b1d9587',
5,
1),

(N'Cheese Cake',
45000,
'https://images.unsplash.com/photo-1533134242443-d4fd215305ad',
5,
1),

(N'Bánh Chocolate',
42000,
'https://images.unsplash.com/photo-1606313564200-e75d5e30476c',
5,
1);

