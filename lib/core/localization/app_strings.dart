import 'package:flutter/material.dart';

class AppStrings {
  static bool isArabic(BuildContext context) {
    return Localizations.localeOf(context).languageCode == 'ar';
  }

  static String tr(BuildContext context, String key) {
    final code = Localizations.localeOf(context).languageCode;
    final map = code == 'ar' ? _ar : _en;
    return map[key] ?? _en[key] ?? key;
  }

  static const Map<String, String> _en = {
    // Header & Nav
    'app_title': 'AUTO GEAR',
    'app_subtitle': 'Aftermarket Auto Parts Catalog',
    'nav_catalog': 'Catalog',
    'nav_makes': 'Makes',
    'nav_systems': 'Systems',
    'nav_about': 'About',
    'nav_contact': 'Contact',
    'browse_parts': 'Browse Parts',
    'my_orders': 'My Orders',
    'sign_in': 'Sign in',
    'sign_out': 'Sign out',
    'cart': 'Cart',

    // Hero Section
    'hero_tag': 'Making Hard-To-Find Auto Parts A Thing Of The Past',
    'hero_headline': 'Reliable Aftermarket Auto Parts\nfor Your Business Success',
    'hero_subheadline':
        'Browse our comprehensive e-catalog of 40,000+ aftermarket auto parts. Filter by make, model, year, and system to find exactly what you need.',
    'search_placeholder': 'Search by part name, SKU, or OEM number...',
    'select_make': 'Select Make',
    'select_model': 'Select Model',
    'select_year': 'Select Year',
    'select_system': 'Select System',
    'select_part': 'Select Part',
    'apply_filters': 'Apply Filters',
    'clear_all': 'Clear All',
    'match_count': 'parts match your filters',

    // Catalog Section
    'parts_catalog': 'Parts Catalog',
    'browse_count': 'Browse {count} auto parts matching your criteria',
    'in_stock': 'In Stock',
    'out_of_stock': 'Out of Stock',
    'add_to_cart': 'Add to cart',
    'sku': 'SKU',
    'oem': 'OEM',
    'vehicle': 'Vehicle',
    'years': 'Years',
    'make': 'Make',
    'model': 'Model',
    'system': 'System',
    'category': 'Category',
    'no_parts_found': 'No parts found',
    'no_parts_sub': 'Try adjusting your filters or search terms to find what you need.',

    // Systems & Makes
    'featured_makes': 'Featured Makes',
    'makes_sub': 'Auto Gear provides parts for a wide range of prominent car manufacturers.',
    'browse_by_system': 'Browse By System',
    'systems_sub': 'Find the exact auto parts you require across all major vehicle systems.',
    'engine_system': 'Engine System',
    'electrical_system': 'Electrical System',
    'braking_system': 'Braking System',
    'suspension_system': 'Suspension & Steering System',
    'cooling_system': 'Cooling System',

    // Stats
    'stat_skus': 'SKUs of Auto Parts',
    'stat_warehouse': 'Warehouse m²',
    'stat_years': 'Years in Export',
    'stat_moq': 'Low MOQ (pcs)',

    // About & Contact
    'about_title': 'About Auto Gear',
    'about_text': 'With over 15 years of industry excellence, Auto Gear is a premier supplier and exporter of high-grade aftermarket auto parts.',
    'contact_title': 'Contact & Inquiries',
    'contact_sub': 'Reach out to our export team for custom quotes, wholesale orders, and inquiries.',
    'address': 'Address',
    'email': 'Email',
    'phone': 'Phone',

    // Cart & Orders
    'cart_empty': 'Your cart is empty',
    'cart_empty_sub': 'Add parts from the catalog to request a quote.',
    'checkout': 'Checkout',
    'quote_on_request': 'Quote on request',
    'order_submitted': 'Order submitted',
    'order_submitted_sub': 'Your quote request #{id} was sent successfully. Our team will contact you shortly.',
    'view_orders': 'View Orders',
    'no_orders': 'No orders found',
    'no_orders_sub': 'When you request quotes from the cart, your orders will appear here.',
    'date': 'Date',
    'items': 'Items',
    'done': 'Done',
    'clear': 'Clear',
  };

  static const Map<String, String> _ar = {
    // Header & Nav
    'app_title': 'أوتو جير',
    'app_subtitle': 'كتالوج قطع غيار السيارات',
    'nav_catalog': 'الكتالوج',
    'nav_makes': 'الماركات',
    'nav_systems': 'الأنظمة',
    'nav_about': 'من نحن',
    'nav_contact': 'اتصل بنا',
    'browse_parts': 'تصفح القطع',
    'my_orders': 'طلباتي',
    'sign_in': 'تسجيل الدخول',
    'sign_out': 'تسجيل الخروج',
    'cart': 'السلة',

    // Hero Section
    'hero_tag': 'نحن نجعل البحث عن قطع الغيار الصعبة أمراً من الماضي',
    'hero_headline': 'قطع غيار سيارات موثوقة\nلنجاح أعمالك وتجارتك',
    'hero_subheadline':
        'تصفح الكتالوج الإلكتروني الشامل لأكثر من 40,000 قطعة غيار. قم بالتصفية حسب الماركة، الموديل، السنة والنظام للعثور على ما تحتاجه بدقة.',
    'search_placeholder': 'ابحث باسم القطعة، الرمز (SKU)، أو الرقم الأصلي (OEM)...',
    'select_make': 'اختر الماركة',
    'select_model': 'اختر الموديل',
    'select_year': 'اختر السنة',
    'select_system': 'اختر النظام',
    'select_part': 'اختر قطعة الغيار',
    'apply_filters': 'تطبيق التصفية',
    'clear_all': 'مسح الكل',
    'match_count': 'قطع تطابق اختيارك',

    // Catalog Section
    'parts_catalog': 'كتالوج قطع الغيار',
    'browse_count': 'تصفح {count} قطعة غيار تطابق معاييرك',
    'in_stock': 'متوفر',
    'out_of_stock': 'غير متوفر',
    'add_to_cart': 'إضافة للسلة',
    'sku': 'رمز القطعة',
    'oem': 'الرقم الأصلي',
    'vehicle': 'السيارة',
    'years': 'السنوات',
    'make': 'الماركة',
    'model': 'الموديل',
    'system': 'النظام',
    'category': 'الفئة',
    'no_parts_found': 'لم يتم العثور على قطع غيار',
    'no_parts_sub': 'جرب تعديل خيارات التصفية أو البحث للعثور على ما تحتاجه.',

    // Systems & Makes
    'featured_makes': 'أبرز الماركات',
    'makes_sub': 'يوفر أوتو جير قطع غيار لمجموعة واسعة من مصنعي السيارات البارزين.',
    'browse_by_system': 'التصفح حسب النظام',
    'systems_sub': 'اعثر على قطع الغيار التي تحتاجها في كافة أنظمة السيارة الرئيسية.',
    'engine_system': 'نظام المحرك',
    'electrical_system': 'النظام الكهربائي',
    'braking_system': 'نظام الفرامل',
    'suspension_system': 'نظام التعليق والتوجيه',
    'cooling_system': 'نظام التبريد',

    // Stats
    'stat_skus': 'صنف من قطع الغيار',
    'stat_warehouse': 'مساحة المستودعات م²',
    'stat_years': 'سنوات من التصدير',
    'stat_moq': 'حد أدنى منخفض للطلب',

    // About & Contact
    'about_title': 'عن أوتو جير',
    'about_text': 'مع أكثر من 15 عاماً من التميز، يُعد أوتو جير مورداً ومصدراً رائداً لقطع غيار السيارات عالية الجودة.',
    'contact_title': 'الاتصال والاستفسارات',
    'contact_sub': 'تواصل مع فريق التصدير للحصول على عروض أسعار مخصصة وطلبات الجملة.',
    'address': 'العنوان',
    'email': 'البريد الإلكتروني',
    'phone': 'الهاتف',

    // Cart & Orders
    'cart_empty': 'سلتك فارغة',
    'cart_empty_sub': 'أضف قطع الغيار من الكتالوج لطلب عرض سعر.',
    'checkout': 'إتمام الطلب',
    'quote_on_request': 'السعر عند الطلب',
    'order_submitted': 'تم تقديم الطلب',
    'order_submitted_sub': 'تم إرسال طلب عرض السعر رقم #{id} بنجاح. سيتواصل معك فريقنا قريباً.',
    'view_orders': 'عرض طلباتي',
    'no_orders': 'لا توجد طلبات',
    'no_orders_sub': 'عندما تطلب عروض أسعار من السلة، ستظهر طلباتك هنا.',
    'date': 'التاريخ',
    'items': 'القطع',
    'done': 'تم',
    'clear': 'مسح',
  };
}
