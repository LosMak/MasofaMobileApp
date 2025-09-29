### Ushbu fayl doimiy amallar(build, fix, build_runner...) uchun qisqa terminal komandalari
### Bitta kommand ichida ko'pgina ketma-ket bajariladigan operatsiyalar yozish mumkin.
### Masalan quyidagi kod, clean qilib pub get qiladi. Terminalga ``make my_command`` yozish kerak.
### my_command:
### 	flutter clean
### 	flutter pub get

# Assetslar uchun generatsiya qilish
res:
	dart run res_generator:generate


# Words uchun tarjima qilish
translate:
	dart run res_generator:translate


# Generatsiya pakagelari uchun, bir martalik generatsiya
gen-once:
	dart run build_runner clean
	dart run build_runner build --delete-conflicting-outputs


# Generatsiya pakagelari uchun, o'zgarishlarni eshitib turadi
gen:
	dart run build_runner watch --delete-conflicting-outputs


# Clean qilish uchun
clean:
	flutter clean
	flutter pub get


# Apk build qilish uchun:
# apk build qiladi, nomini bir_qadam_sana.apk ko'rinisiga o'tkazadi
# papkani ochadi, gitdagi joriy branchdagi ohirgi 5 commitni, changes.txtga saqlaydi
build-apk:
	flutter clean
	flutter build apk --release
	@name=masofa-yer \
	version	=$$(grep '^version:' pubspec.yaml | awk '{print $$2}' | cut -d '+' -f 1); \
	date=$$(date +%d.%m.%Y); \
	build=$$(grep '^build_type:' pubspec.yaml | awk '{print $$2}' | tr -d '[:space:]'); \
	filename="$$name-v$$version-$$date-$$build.apk"; \
	mv ./build/app/outputs/flutter-apk/app-release.apk "./build/app/outputs/flutter-apk/$$filename"
	open ./build/app/outputs/flutter-apk/

build-apk-masofa:
	rm -f ./assets/icons/logo.svg
	cp ./assets/icons/masofa_yer_logo.svg ./assets/icons/logo.svg
	rm -f ./assets/images/logo.png
	cp ./assets/images/masofa_yer_logo.png ./assets/images/logo.png
	dart run rename_app:main android="Masofa yer"
	flutter clean
	flutter pub get
	flutter pub run flutter_launcher_icons:main
	dart run res_generator:generate
	flutter build apk --release
	@name=masofa-yer \
	version	=$$(grep '^version:' pubspec.yaml | awk '{print $$2}' | cut -d '+' -f 1); \
	date=$$(date +%d.%m.%Y); \
	build=$$(grep '^build_type:' pubspec.yaml | awk '{print $$2}' | tr -d '[:space:]'); \
	filename="$$name-v$$version-$$date-$$build.apk"; \
	mv ./build/app/outputs/flutter-apk/app-release.apk "./build/app/outputs/flutter-apk/$$filename"

build-apk-ugm:
	rm -f ./assets/icons/logo.svg
	cp ./assets/icons/agb_rounded_logo.svg ./assets/icons/logo.svg
	rm -f ./assets/images/logo.png
	cp ./assets/images/agb_logo.png ./assets/images/logo.png
	dart run rename_app:main android="Fields"
	flutter clean
	flutter pub get
	flutter pub run flutter_launcher_icons:main
	dart run res_generator:generate
	flutter build apk --release
	@name=Fields \
	version=$$(grep '^version:' pubspec.yaml | awk '{print $$2}' | cut -d '+' -f 1); \
	date=$$(date +%d.%m.%Y); \
	build=$$(grep '^build_type:' pubspec.yaml | awk '{print $$2}' | tr -d '[:space:]'); \
	filename="$$name-v$$version-$$date-$$build.apk"; \
	mv ./build/app/outputs/flutter-apk/app-release.apk "./build/app/outputs/flutter-apk/$$filename"

# iosda uchrab turadigan odatiy xatoliklarni oldini oladi
fix-ios:
	cd ios; pod cache clean --all; pod clean; pod deintegrate; sudo gem install cocoapods-deintegrate cocoapods-clean; sudo arch -x86_64 gem install ffi; arch -x86_64 pod repo update; arch -x86_64 pod install


# Dastur kodida uchrab turadigan odatiy xatoliklarni oldini oladi. Bir martalik generatsiya
fix:
	dart fix --apply


# Dasturni release versiyada 00008110-001C35D90AEB801E shu idlik deviceda ishga tushurish
# O'ziningizga moslab olishingiz mumkin. Hozir buyerda o'zimni telefonim.
run:
	flutter run -d  00008110-001C35D90AEB801E --release


# Prompt generate qilish uchun
prompt:
	dart run prompt_generator:generate


gen-api-client:
	rm -r ./api_client
	openapi-generator generate \
		-i http://185.100.234.107:30020/swagger/Common/swagger.json \
		-g dart-dio -o api_client/common \
		--additional-properties=pubName=api_client_common,useEnumExtension=true,nullableFields=false \
		--model-name-suffix=Model && \
	cd api_client/common && \
	dart pub get && \
	dart run build_runner build --delete-conflicting-outputs && \
	cd ../..

	openapi-generator generate \
		-i http://185.100.234.107:30020/swagger/Identity/swagger.json \
		-g dart-dio -o api_client/identity \
		--additional-properties=pubName=api_client_identity,useEnumExtension=true,nullableFields=false \
		--model-name-suffix=Model && \
	cd api_client/identity && \
	dart pub get && \
	dart run build_runner build --delete-conflicting-outputs && \
	cd ../..

	openapi-generator generate \
		-i http://185.100.234.107:30020/swagger/Dictionaries/swagger.json \
		-g dart-dio -o api_client/dictionaries \
		--additional-properties=pubName=api_client_dictionaries,useEnumExtension=true,nullableFields=false \
		--model-name-suffix=Model && \
	cd api_client/dictionaries && \
	dart pub get && \
	dart run build_runner build --delete-conflicting-outputs && \
	cd ../..

	openapi-generator generate \
		-i http://185.100.234.107:30020/swagger/CropMonitoring/swagger.json \
		-g dart-dio -o api_client/crop \
		--additional-properties=pubName=api_client_crop,useEnumExtension=true,nullableFields=false \
		--model-name-suffix=Model && \
	cd api_client/crop && \
	dart pub get && \
	dart run build_runner build --delete-conflicting-outputs && \
	cd ../..