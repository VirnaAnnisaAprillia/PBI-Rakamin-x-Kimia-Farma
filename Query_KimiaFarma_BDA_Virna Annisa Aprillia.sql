-- Membuat atau mengganti tabel kf_summary_analysis 
CREATE OR REPLACE TABLE `rakamin-kf-analytics-449310.kimia_farma.kf_summary_analysis` AS  

SELECT  
    -- Mengambil ID transaksi dan tanggal transaksi
    ft.transaction_id,  
    ft.date,  
    -- Mengambil informasi cabang dari tabel kantor_cabang  
    ft.branch_id,  
    kc.branch_name,  -- Nama cabang  
    kc.kota,         -- Kota cabang  
    kc.provinsi,     -- Provinsi cabang  
    kc.rating AS rating_cabang,  -- Rating cabang berdasarkan review pelanggan  
    -- Mengambil informasi pelanggan  
    ft.customer_name,  
    -- Mengambil informasi produk dari tabel product  
    ft.product_id,  
    p.product_name,  -- Nama produk  
    -- Mengambil harga awal produk sebelum diskon  
    ft.price AS actual_price,  
    -- Mengambil persentase diskon  
    ft.discount_percentage,  

    -- Menghitung persentase gross laba berdasarkan harga produk  
    CASE  
        WHEN ft.price <= 50000 THEN 0.10  -- Jika harga ≤ 50.000, laba 10%  
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15  -- Jika harga 50.000 - 100.000, laba 15%  
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.20  -- Jika harga 100.000 - 300.000, laba 20%  
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25  -- Jika harga 300.000 - 500.000, laba 25%  
        ELSE 0.30  -- Jika harga > 500.000, laba 30%  
    END AS persentase_gross_laba,  
    -- Menghitung nett sales (pendapatan setelah diskon)  
    ft.price * (1 - ft.discount_percentage / 100) AS nett_sales,  

    -- Menghitung nett profit berdasarkan nett sales dan persentase laba  
    (ft.price * (1 - ft.discount_percentage / 100)) *  
    CASE  
        WHEN ft.price <= 50000 THEN 0.10  
        WHEN ft.price > 50000 AND ft.price <= 100000 THEN 0.15  
        WHEN ft.price > 100000 AND ft.price <= 300000 THEN 0.20  
        WHEN ft.price > 300000 AND ft.price <= 500000 THEN 0.25  
        ELSE 0.30  
    END AS nett_profit,  

    -- Mengambil rating transaksi dari pelanggan  
    ft.rating AS rating_transaksi  
    
-- Menghubungkan tabel transaksi dengan tabel produk dan cabang  
FROM `rakamin-kf-analytics-449310.kimia_farma.kf_final_transaction` ft  
LEFT JOIN `rakamin-kf-analytics-449310.kimia_farma.kf_product` p  
    ON ft.product_id = p.product_id  
LEFT JOIN `rakamin-kf-analytics-449310.kimia_farma.kf_kantor_cabang` kc  
    ON ft.branch_id = kc.branch_id;

