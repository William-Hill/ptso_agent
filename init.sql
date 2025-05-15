-- Create a single table for weather data
CREATE TABLE IF NOT EXISTS weather_data (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    temp FLOAT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_weather_data_id ON weather_data(id);
CREATE INDEX IF NOT EXISTS idx_weather_data_name ON weather_data(name);
CREATE INDEX IF NOT EXISTS idx_weather_data_timestamp ON weather_data(timestamp);

-- Create ENUM types for season and style
CREATE TYPE season_type AS ENUM ('All Season', 'Summer', 'Fall/Winter', 'Spring');
CREATE TYPE style_type AS ENUM ('Casual', 'Formal', 'Athletic', 'Business', 'Business Casual', 'Essential', 'Streetwear');

-- Create ENUM types for garment type and category
CREATE TYPE garment_type_enum AS ENUM (
    'T-Shirt', 'Shirt', 'Polo', 'Sweater', 'Hoodie', 'Tank Top', 'Blazer', 'Jacket', 'Coat', 'Vest',
    'Pants', 'Shorts', 'Jogger', 'Sneakers', 'Dress Shoes', 'Cap', 'Tie'
);

CREATE TYPE garment_category_enum AS ENUM (
    'Tops', 'Bottoms', 'Footwear', 'Outerwear', 'Accessories'
);

-- Create wardrobe table
CREATE TABLE IF NOT EXISTS wardrobe (
    id SERIAL PRIMARY KEY,
    brand VARCHAR(100) NOT NULL,
    item_name VARCHAR(255) NOT NULL,
    color VARCHAR(100) NOT NULL,
    garment_type garment_type_enum NOT NULL,
    garment_category garment_category_enum NOT NULL,
    fabric VARCHAR(255),
    size VARCHAR(50),
    price DECIMAL(10,2),
    purchase_date DATE,
    season season_type NOT NULL,
    style style_type NOT NULL,
    care_instructions TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_wardrobe_brand ON wardrobe(brand);
CREATE INDEX IF NOT EXISTS idx_wardrobe_garment_category ON wardrobe(garment_category);
CREATE INDEX IF NOT EXISTS idx_wardrobe_style ON wardrobe(style);
CREATE INDEX IF NOT EXISTS idx_wardrobe_season ON wardrobe(season);

-- Insert initial wardrobe data
INSERT INTO wardrobe (
    brand, 
    item_name, 
    color, 
    garment_type, 
    garment_category, 
    fabric, 
    size, 
    price, 
    purchase_date, 
    season, 
    style, 
    care_instructions
) VALUES 
-- Initial items
('Bonobos', 'Stretch Washed Chino', 'Navy', 'Pants', 'Bottoms', '98% Cotton, 2% Elastane', '34x32', 89.00, '2024-03-15', 'All Season', 'Casual', 'Machine wash cold, tumble dry low'),
('Bonobos', 'Weekday Warrior Blazer', 'Charcoal', 'Blazer', 'Outerwear', 'Wool Blend', 'L', 198.00, '2024-03-12', 'All Season', 'Business Casual', 'Dry clean only'),
('Bonobos', 'Highland Golf Shorts', 'Khaki', 'Shorts', 'Bottoms', 'Performance Stretch', '34', 69.00, '2024-03-08', 'Summer', 'Athletic', 'Machine wash cold'),
('Bonobos', 'Merino Wool Crewneck Sweater', 'Forest Green', 'Sweater', 'Tops', '100% Merino Wool', 'L', 98.00, '2024-03-01', 'Fall/Winter', 'Business Casual', 'Dry clean only'),
('Bonobos', 'Wool Cashmere Overcoat', 'Camel', 'Coat', 'Outerwear', 'Wool Cashmere Blend', 'L', 298.00, '2024-03-01', 'Fall/Winter', 'Business', 'Dry clean only'),
('Bonobos', 'Flannel Shirt', 'Black Watch', 'Shirt', 'Tops', '100% Cotton Flannel', 'L', 79.00, '2024-03-01', 'Fall/Winter', 'Casual', 'Machine wash cold'),
('Bonobos', 'Corduroy Pants', 'Burgundy', 'Pants', 'Bottoms', '100% Cotton Corduroy', '34x32', 89.00, '2024-03-01', 'Fall/Winter', 'Casual', 'Machine wash cold'),
('Bonobos', 'Quilted Vest', 'Navy', 'Vest', 'Outerwear', 'Nylon Shell, Polyester Fill', 'L', 128.00, '2024-03-01', 'Fall/Winter', 'Casual', 'Machine wash cold'),
('Bonobos', 'Linen Shirt', 'Light Blue', 'Shirt', 'Tops', '100% Linen', 'L', 89.00, '2024-03-01', 'Summer', 'Casual', 'Machine wash cold, hang dry'),
('Bonobos', 'Performance Golf Polo', 'White', 'Polo', 'Tops', 'Performance Pique', 'L', 59.00, '2024-03-01', 'Summer', 'Athletic', 'Machine wash cold'),
('Bonobos', 'Stretch Washed Chino Shorts', 'Olive', 'Shorts', 'Bottoms', '98% Cotton, 2% Elastane', '34', 69.00, '2024-03-01', 'Summer', 'Casual', 'Machine wash cold'),
('Bonobos', 'Lightweight Oxford Shirt', 'Pink', 'Shirt', 'Tops', 'Lightweight Cotton Oxford', 'L', 79.00, '2024-03-01', 'Summer', 'Business Casual', 'Machine wash cold'),
('Bonobos', 'Performance Golf Pants', 'Navy', 'Pants', 'Bottoms', 'Performance Stretch', '34x32', 89.00, '2024-03-01', 'Summer', 'Athletic', 'Machine wash cold'),
('Bonobos', 'Seersucker Shirt', 'Blue/White', 'Shirt', 'Tops', '100% Cotton Seersucker', 'L', 79.00, '2024-03-01', 'Summer', 'Business Casual', 'Machine wash cold'),
('Cuts Clothing', 'Classic Crew T-Shirt', 'White', 'T-Shirt', 'Tops', '100% Premium Cotton', 'L', 48.00, '2024-03-10', 'All Season', 'Essential', 'Machine wash cold, hang dry'),
('Cuts Clothing', 'The Bomber Jacket', 'Black', 'Jacket', 'Outerwear', 'Premium Nylon', 'L', 248.00, '2024-03-01', 'Fall/Winter', 'Streetwear', 'Spot clean only'),
('Cuts Clothing', 'The Jogger', 'Navy', 'Pants', 'Bottoms', 'Premium French Terry', '34x32', 98.00, '2024-03-05', 'All Season', 'Athletic', 'Machine wash cold'),
('Cuts Clothing', 'The Performance Polo', 'Navy', 'Polo', 'Tops', 'Performance Pique', 'L', 68.00, '2024-03-01', 'Summer', 'Athletic', 'Machine wash cold'),
('Cuts Clothing', 'The Performance Short', 'Black', 'Shorts', 'Bottoms', 'Performance Stretch', '34', 78.00, '2024-03-01', 'Summer', 'Athletic', 'Machine wash cold'),
('Cuts Clothing', 'The Linen Shirt', 'White', 'Shirt', 'Tops', '100% Linen', 'L', 98.00, '2024-03-01', 'Summer', 'Casual', 'Machine wash cold, hang dry'),
('Cuts Clothing', 'The Performance Tank', 'Grey', 'Tank Top', 'Tops', 'Performance Stretch', 'L', 48.00, '2024-03-01', 'Summer', 'Athletic', 'Machine wash cold'),
('Cuts Clothing', 'The Performance Short Sleeve', 'Black', 'T-Shirt', 'Tops', 'Performance Stretch', 'L', 58.00, '2024-03-01', 'Summer', 'Athletic', 'Machine wash cold'),
('Nike Jordan', 'Air Jordan 4 Retro A Ma Maniere', 'Fossil Stone', 'Sneakers', 'Footwear', 'Premium Leather and Suede', '10', 250.00, '2024-03-01', 'All Season', 'Athletic', 'Clean with soft brush, air dry'),
('Nike Jordan', 'Air Jordan 4 Retro SB Pine Green', 'Pine Green/Black', 'Sneakers', 'Footwear', 'Premium Leather and Mesh', '10', 225.00, '2024-03-01', 'All Season', 'Athletic', 'Clean with soft brush, air dry'),
('Nike Jordan', 'Air Jordan 4 Retro Union Guava Ice', 'Guava Ice/Black', 'Sneakers', 'Footwear', 'Premium Leather and Mesh', '10', 275.00, '2024-03-01', 'All Season', 'Athletic', 'Clean with soft brush, air dry'),
('Nike Jordan', 'Air Jordan 4 Retro Alternate 89', 'White/Black/Red', 'Sneakers', 'Footwear', 'Premium Leather and Mesh', '10', 210.00, '2024-03-01', 'All Season', 'Athletic', 'Clean with soft brush, air dry'),
('Nike Jordan', 'Air Jordan 1 High OG Spider-Man Across the Spider-Verse', 'Black/Red/Blue', 'Sneakers', 'Footwear', 'Premium Leather and Mesh', '10', 180.00, '2024-03-01', 'All Season', 'Athletic', 'Clean with soft brush, air dry'),
('Nike Jordan', 'Air Jordan 12 Retro Eastside Golf', 'White/Green', 'Sneakers', 'Footwear', 'Premium Leather and Mesh', '10', 225.00, '2024-03-01', 'All Season', 'Athletic', 'Clean with soft brush, air dry'),
('Nike SB', 'Dunk Low Jarritos', 'Green/Orange', 'Sneakers', 'Footwear', 'Premium Leather and Suede', '10', 165.00, '2024-03-01', 'All Season', 'Athletic', 'Clean with soft brush, air dry'),
('Cole Haan', 'Original Grand Wingtip Oxford', 'Black', 'Dress Shoes', 'Footwear', 'Leather', '10', 198.00, '2024-02-28', 'All Season', 'Formal', 'Professional cleaning recommended'),
('Nike Jordan', 'Jordan Essentials Hoodie', 'Grey', 'Hoodie', 'Tops', 'Cotton Blend', 'L', 85.00, '2024-03-10', 'Fall/Winter', 'Athletic', 'Machine wash cold'),
('Nike Jordan', 'Jordan Flight Heritage Cap', 'Black', 'Cap', 'Accessories', 'Polyester', 'OSFA', 32.00, '2024-03-15', 'All Season', 'Athletic', 'Hand wash'),
('Cole Haan', 'Zerogrand Wingtip Oxford', 'Brown', 'Dress Shoes', 'Footwear', 'Leather and Mesh', '10', 228.00, '2024-03-07', 'All Season', 'Business Casual', 'Professional cleaning recommended'),
('Cole Haan', 'Grandpro Tennis Sneaker', 'White', 'Sneakers', 'Footwear', 'Leather', '10', 130.00, '2024-03-14', 'All Season', 'Athletic', 'Clean with soft brush'),

-- DressCode items (updated to match actual products)
('DressCode', 'code.ture-hoodie', 'Black', 'Hoodie', 'Tops', 'Premium Cotton Blend', 'L', 80.00, '2024-03-01', 'Fall/Winter', 'Streetwear', 'Machine wash cold'),
('DressCode', 'code.ture-jckt', 'Black', 'Jacket', 'Outerwear', 'Premium Nylon', 'L', 149.99, '2024-03-01', 'Fall/Winter', 'Streetwear', 'Spot clean only'),
('DressCode', 'Code.zy-midnite', 'Black', 'T-Shirt', 'Tops', '100% Cotton', 'L', 80.00, '2024-03-15', 'All Season', 'Streetwear', 'Machine wash cold'),
('DressCode', 'error404-black.swtr', 'Black', 'Sweater', 'Tops', 'Premium Cotton Blend', 'L', 64.99, '2024-03-15', 'Fall/Winter', 'Streetwear', 'Machine wash cold'),
('DressCode', 'Future of Health Hoodie', 'Black', 'Hoodie', 'Tops', 'Premium Cotton Blend', 'L', 80.00, '2024-03-15', 'Fall/Winter', 'Streetwear', 'Machine wash cold');

-- Create helpful views for common queries
CREATE OR REPLACE VIEW seasonal_items AS
SELECT brand, item_name, color, garment_type, season, price
FROM wardrobe
ORDER BY season, garment_category;

CREATE OR REPLACE VIEW wardrobe_by_brand AS
SELECT brand, COUNT(*) as item_count, SUM(price) as total_value
FROM wardrobe
GROUP BY brand
ORDER BY item_count DESC;

CREATE OR REPLACE VIEW wardrobe_by_category AS
SELECT garment_category, COUNT(*) as item_count, SUM(price) as total_value
FROM wardrobe
GROUP BY garment_category
ORDER BY item_count DESC;

-- Add some helpful comments for future reference
COMMENT ON TABLE wardrobe IS 'Main wardrobe inventory table containing all clothing items';
COMMENT ON COLUMN wardrobe.garment_category IS 'High-level category: Tops, Bottoms, Footwear, Outerwear, Accessories';
COMMENT ON COLUMN wardrobe.style IS 'Style classification: Casual, Formal, Athletic, Business, Essential, etc';
COMMENT ON COLUMN wardrobe.season IS 'Seasonal availability: All Season, Summer, Fall/Winter, etc'; 