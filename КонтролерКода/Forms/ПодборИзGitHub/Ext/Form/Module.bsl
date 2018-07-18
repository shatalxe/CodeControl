﻿#Область ОписаниеПеременных
&НаКлиенте
Перем МассивФайловКоммита;
&НаКлиенте
Перем СерверApi;
#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если Параметры.Свойство("АдресМассиваФайловGitHub") Тогда
		АдресМассиваФайловGitHub = Параметры.АдресМассиваФайловGitHub;
	КонецЕсли;

КонецПроцедуры

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбновитьСписокКоммитов();
	ОбновитьСписокФайлов();
	ОбновитьСвойстваЭлементовФормы();
	
КонецПроцедуры


#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

&НаКлиенте
Процедура СommitПриИзменении(Элемент)
	
	ОбновитьСписокФайлов();
	ОбновитьСвойстваЭлементовФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура filesВыбор(Элемент, ВыбраннаяСтрока, Поле, СтандартнаяОбработка)
	
	ВыбратьТекущийФайлИЗакрыть();
	
КонецПроцедуры

&НаКлиенте
Процедура OwnerПриИзменении(Элемент)
	ОбновитьСписокКоммитов();
	ОбновитьАдресКоммита();
КонецПроцедуры
&НаКлиенте
Процедура RepoПриИзменении(Элемент)
	ОбновитьСписокКоммитов();
	ОбновитьАдресКоммита();
КонецПроцедуры
&НаКлиенте
Процедура authorПриИзменении(Элемент)
	ОбновитьСписокКоммитов();
КонецПроцедуры

&НаКлиенте
Процедура СommitsПриАктивизацииСтроки(Элемент)
	
	ТекДанные = Элементы.Сommits.ТекущиеДанные;
	
	Если ТекДанные <> Неопределено Тогда
		commitID = ТекДанные.sha;
	КонецЕсли;
		
	ОбновитьАдресКоммита();
	ОбновитьСписокФайлов();
	ОбновитьСвойстваЭлементовФормы();
	
КонецПроцедуры

&НаКлиенте
Процедура authorНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Если Не ПроверитьЗаполнение() Тогда
		Возврат;
	КонецЕсли;
	
	// https://api.github.com/repos/shatalxe/CodeControl/assignees
				
	ТекстЗапроса = СтрШаблон("/repos/%1/%2/assignees",Owner,Repo);
	
	HTTPОтвет = ПолучитьHTTPОтвет(СерверApi,ТекстЗапроса);
	
	Если Не ОтветСодержитДанные(HTTPОтвет) Тогда
		Возврат;
	КонецЕсли;
	
	Данные = ПолучитьJSON(HTTPОтвет);
	Список = Новый СписокЗначений;
	
	Для Каждого Структура Из Данные Цикл 
		Список.Добавить(Структура.login);
	КонецЦикла;

	Список.ПоказатьВыборЭлемента(Новый ОписаниеОповещения("authorНачалоВыбораЗавершение", ЭтаФорма));
	
КонецПроцедуры

&НаКлиенте
Процедура authorНачалоВыбораЗавершение(ВыбранныйЭлемент, ДополнительныеПараметры) Экспорт
	
	Если ВыбранныйЭлемент = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	author = ВыбранныйЭлемент;
	
	ОбновитьСписокКоммитов();
	ОбновитьСписокФайлов();
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы
&НаКлиенте
Процедура Перенести(Команда)
	
	ВыбратьТекущийФайлИЗакрыть();
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаКлиенте
Процедура ВыбратьТекущийФайлИЗакрыть()
	
	ТекДанные = Элементы.files.ТекущиеДанные;
	
	Если ТекДанные = Неопределено Тогда
		Закрыть();	
	КонецЕсли;

	ПоместитьВоВременноеХранилище(МассивФайловКоммита,АдресМассиваФайловGitHub);

	Закрыть(files.Индекс(ТекДанные));
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьАдресКоммита()
	
	//https://github.com/shatalxe/CodeControl/commit/2446bbbd40bb469558cd77966aeba9fb5d2f2c0a

	Сommit = СтрШаблон("https://github.com/%1/%2/commit/%3",Owner,Repo,commitID);
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСвойстваЭлементовФормы();
	
	Элементы.ФормаПеренести.Доступность = files.Количество()>0;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокКоммитов()
	
	// https://api.github.com/repos/shatalxe/CodeControl/commits?author=AKhabarov
	Сommits.Очистить();
	
	Фильтр = "";
	
	Если Не ПустаяСтрока(author) Тогда
		Фильтр = СтрШаблон("?author=%1",author);
	КонецЕсли;
		
	ТекстЗапроса = СтрШаблон("/repos/%1/%2/commits%3",Owner,Repo,Фильтр);
	
	HTTPОтвет = ПолучитьHTTPОтвет(СерверApi,ТекстЗапроса);
	
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		Возврат;
	КонецЕсли;
	
	Данные = ПолучитьJSON(HTTPОтвет);
	
	Для Каждого Структура Из Данные Цикл 
		
		НоваяСтрока = Сommits.Добавить();
		НоваяСтрока.login = Структура.commit.author.name;
		НоваяСтрока.message = Структура.commit.message;
		НоваяСтрока.sha = Структура.sha;
		
		Части = СтрРазделить(Структура.commit.author.date,"-TZ:",Ложь);
		НоваяСтрока.date = Дата(Части[0],Части[1],Части[2],Части[3],Части[4],Части[5]);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокФайлов()
	
	files.Очистить();
	
	АдресПоЧастям = СтрРазделить(Сommit,"/",Ложь);
	Если АдресПоЧастям.Количество() <> 6 Тогда
		Возврат;
	КонецЕсли;
	
	Owner 		= АдресПоЧастям[2];
	Repo  		= АдресПоЧастям[3];
	commitID    = АдресПоЧастям[5];
	
	ТекстЗапроса = СтрШаблон("/repos/%1/%2/commits/%3",Owner,Repo,commitID);
	
	HTTPОтвет = ПолучитьHTTPОтвет(СерверApi,ТекстЗапроса);
	 
	Если HTTPОтвет.КодСостояния <> 200 Тогда
		Возврат;
	КонецЕсли;
	
	ДанныеКоммита = ПолучитьJSON(HTTPОтвет);
	
	МассивФайловКоммита = ДанныеКоммита.files;
	
	Для Каждого Файл Из МассивФайловКоммита Цикл 
		ЗаполнитьЗначенияСвойств(files.Добавить(),Файл);
	КонецЦикла;
		
КонецПроцедуры

&НаКлиенте
Функция ПолучитьHTTPОтвет(Сервер,ТекстЗапроса,ИмяВыходногоФайла = Неопределено) Экспорт
	
	HTTPЗапрос = Новый HTTPЗапрос(ТекстЗапроса);
	HTTPСоединение = Новый HTTPСоединение(Сервер,,,,,,Новый ЗащищенноеСоединениеOpenSSL);
	Возврат HTTPСоединение.Получить(HTTPЗапрос, ИмяВыходногоФайла);
	
КонецФункции

&НаКлиенте
Функция ПолучитьJSON(HTTPОтвет);
	
	JSON = Новый ЧтениеJSON;
	JSON.УстановитьСтроку(HTTPОтвет.ПолучитьТелоКакСтроку());
	Возврат ПрочитатьJSON(JSON);
	
КонецФункции

&НаКлиенте
Функция РазобратьАдресНаИмяСервераИЗапрос(Адрес) Экспорт
	
	Результат = Новый Структура("Сервер,Запрос");
	
	Результат.Сервер = СтрРазделить(Адрес,"/")[2];
	Результат.Запрос = Сред(Адрес,СтрНайти(Адрес,Результат.Сервер)+СтрДлина(Результат.Сервер));
	
	Возврат Результат;
	
КонецФункции

&НаКлиенте
Функция ОтветСодержитДанные(HTTPОтвет) Экспорт
		
	Если HTTPОтвет.КодСостояния = 200 Тогда
		Возврат Истина;
	КонецЕсли;
	
	СодержимоеОтвета = СтрШаблон("Сервер вернул код состояния %1", HTTPОтвет.КодСостояния);	
	
	Для Каждого КлючИЗначение Из HTTPОтвет.Заголовки Цикл
		СодержимоеОтвета = СодержимоеОтвета + Символы.ПС + СтрШаблон("%1=%2",КлючИЗначение.Ключ,КлючИЗначение.Значение);		
	КонецЦикла;
	
	ПоказатьПредупреждение(,СодержимоеОтвета);

	Возврат Ложь;
	
КонецФункции

#КонецОбласти

СерверApi = "api.github.com";