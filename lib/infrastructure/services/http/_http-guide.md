# HTTP Service Qo'llanmasi

Bu qo'llanma Flutter loyihalarida HTTP xizmatlaridan foydalanish uchun mo'ljallangan. Qo'llanma ikki qismdan iborat: dasturchilar uchun va AI uchun.

## Dasturchilar uchun qo'llanma

### 1. Tarkib va asosiy tuzilma

HTTP service quyidagi komponentlardan iborat:

- **HttpService** - asosiy xizmat sinfi
- **Interceptorlar**:
  - `TokenInterceptor` - autentifikatsiya tokeni bilan ishlash
  - `MyLogInterceptor` - so'rovlar va javoblarni qayd qilish
  - `ConnectionCheckerInterceptor` - internet ulanishni tekshirish
- **Cache mexanizmi** - Dio Cache Interceptor orqali

### 2. HttpService konfiguratsiyasi

`HttpService` sinfi barcha HTTP so'rovlarini boshqaradi va quyidagi parametrlarni qabul qiladi:

```dart
Dio client({
  required bool requiredRemote,   // Internet ulanish kerakmi
  required bool requiredToken,    // Token kerakmi
  Duration? cacheDuration,        // Kesh davomiyligi
  String? baseUrl,                // Asosiy URL
  Duration? receiveTimeout,       // Qabul qilish timeout
  Duration? sendTimeout,          // Yuborish timeout
  Duration? connectTimeout,       // Ulanish timeout
});
```

### 3. TokenInterceptor'ni sozlash

Loyihalar uchun eng ko'p o'zgartiriladigan qism - `TokenInterceptor`. Ushbu sinf autentifikatsiya tokenlarini boshqaradi va ularni yangilaydi.

Odatiy token yangilash uchun:

```dart
// Yangi token olish uchun
final dio = Dio(BaseOptions(baseUrl: AppConstants.authUrl));
final response = await dio.post(
  path,
  data: tokenData,
  options: Options(headers: headers),
);

// Tokenni saqlash
await _cache.setToken(response.data["access_token"]);
```

Autentifikatsiya uchun ma'lumotlarni o'zgartirish zarur bo'lsa, faqat `data` parametrini o'zgartiring:

```dart
final data = {
  "username": _cache.login,
  "password": _cache.password,
  "grant_type": "password",
  // Bu qatorlar loyihangiz API talablariga qarab o'zgartiriladi
  "client_secret": "YOUR_CLIENT_SECRET",
  "client_id": "YOUR_CLIENT_ID",
  "scope": "YOUR_SCOPE",
};
```

### 4. Keshni sozlash

Kesh mexanizmini sozlash uchun `di_module.dart` faylidagi `cacheOptions` va `hiveCacheStore` parametrlarini o'zgartiring:

```dart
@preResolve
Future<CacheOptions> get cacheOptions async {
  return CacheOptions(
    store: await hiveCacheStore,
    policy: CachePolicy.forceCache,
    // Boshqa parametrlar ...
  );
}
```

### 5. HTTP serviceni ishlatish misollar

So'rov yuborish:

```dart
final httpService = getIt<HttpService>();
final dio = httpService.client(
  requiredRemote: true,
  requiredToken: true,
);

try {
  final response = await dio.get('/api/endpoint');
  // response.data bilan ishlash
} catch (e) {
  // Xatolikni bartaraf etish
}
```

Keshli so'rov:

```dart
final dio = httpService.client(
  requiredRemote: true,
  requiredToken: true,
  cacheDuration: const Duration(minutes: 30),
);
```

Faqat mahalliy keshdan o'qish:

```dart
final dio = httpService.client(
  requiredRemote: false,
  requiredToken: true,
  cacheDuration: const Duration(days: 1),
);
```

## AI uchun qo'llanma

### HTTP Service haqida umumiy ma'lumot

Bu loyiha Dio HTTP mijozi atrofida qurilgan modulyar HTTP xizmatidir. U quyidagi asosiy funksiyalarni ta'minlaydi:

1. **Token boshqaruvi**: Autentifikatsiya tokenlarini avtomatik qo'shish va yangilash.
2. **Kesh mexanizmi**: So'rovlarni keshlash va oflayn rejimda ishlash.
3. **Internet ulanish tekshiruvi**: Internet mavjudligini tekshirish.
4. **Xatoliklarni qayta ishlash**: 401 xatoligi (ruxsatsiz) yuzaga kelganda token yangilash.

### Interceptorlar tuzilishi va funksiyalari

1. **TokenInterceptor**:
   - `onRequest`: So'rovga bearer tokenni qo'shadi.
   - `onError`: 401 xatoligida tokenni yangilaydi yoki foydalanuvchini login ekraniga yo'naltiradi.

2. **ConnectionCheckerInterceptor**:
   - Internet ulanishini tekshiradi va mavjud bo'lmaganda so'rovlarni bloklaydi.

3. **MyLogInterceptor**:
   - Debug rejimida so'rovlar va javoblarni log qiladi.

### Konfiguratsiya parametrlari

- `requiredRemote`: Internet ulanish kerakmi (true) yoki faqat keshdan o'qish kerakmi (false).
- `requiredToken`: So'rov uchun token kerakmi.
- `cacheDuration`: So'rovlar uchun kesh davomiyligi.

### Token yangilash mexanizmi

TokenInterceptor 401 xatoligi yuzaga kelganda quyidagi jarayonni bajaradi:

1. Foydalanuvchi login va parolini tekshiradi.
2. Agar mavjud bo'lsa, yangi token olish uchun autentifikatsiya so'rovini yuboradi.
3. Yangi tokenni saqlaydi va boshlang'ich so'rovni takrorlaydi.
4. Muvaffaqiyatsizlik holatida foydalanuvchini login ekraniga yo'naltiradi.

### Kod generatsiyasi uchun maslahatlar

Interceptorlarni loyiha talablariga moslashtirish:

```dart
class CustomTokenInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Token qo'shish logikasi
  }
  
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Token yangilash logikasi
  }
}
```

HttpService'ni ishlatish:

```dart
final dio = httpService.client(
  requiredRemote: true,  // Internet kerak
  requiredToken: true,   // Token kerak
  cacheDuration: const Duration(hours: 1),  // 1 soat kesh
);

final response = await dio.get('/endpoint');
```

### Xavfsizlik maslahalari

- Token saqlash uchun xavfsiz saqlash mexanizmidan foydalaning (Secure Storage, Keychain, yoki shifrlangan Hive).
- Sensitiv ma'lumotlarni log qilishdan saqlaning.
- API kalitlari, client secretlarni ochiq kodda saqlamang.
