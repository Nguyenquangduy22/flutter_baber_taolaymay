

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_baber_taolaymay/cloud_firestore/all_salon_ref.dart';
import 'package:flutter_baber_taolaymay/model/barber_model.dart';
import 'package:flutter_baber_taolaymay/model/booking_model.dart';
import 'package:flutter_baber_taolaymay/model/city_model.dart';
import 'package:flutter_baber_taolaymay/model/salon_model.dart';
import 'package:flutter_baber_taolaymay/state/state_management.dart';
import 'package:flutter_baber_taolaymay/utils/utils.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:im_stepper/stepper.dart';
import 'package:intl/intl.dart';

class BookingScreen extends ConsumerWidget{
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey();
  @override
  Widget build(BuildContext context, watch) {
    var step = watch(currentStep).state;
    var cityWatch = watch(selectedCity).state;
    var salonWatch = watch(selectedSalon).state;
    var barberWatch = watch(selectedBarber).state;
    var dateWatch = watch(selectedDate).state;
    var timeWatch = watch(selectedTime).state;
    var timeSlotWatch = watch(selectedTimeSlot).state;

    var test = context.read(selectedCity).state;
    print(test);
    return SafeArea(
        child: Scaffold(
          key: scaffoldKey,
          appBar: AppBar(title: Text('Booking'),backgroundColor: Color(0xFF383838),),
          resizeToAvoidBottomInset: true,
          backgroundColor: Color(0xFFFDF9EE),

          body: Column(children: [
            //Steps
            NumberStepper(
              activeStep: step-1,
              direction: Axis.horizontal,
              enableNextPreviousButtons: false,
              enableStepTapping: false,
              numbers: [1,2,3,4,5],
              stepColor: Colors.blue,
              activeStepBorderColor: Colors.indigoAccent,
              numberStyle: TextStyle(color: Colors.white),
            ),
            //Screen
            Expanded(
              flex: 10,
              child: step == 1
                ? displayCityList()
                : step == 2
                    ? displaySalon(cityWatch.name)
              : step == 3 ? displayBarber(salonWatch) :
                   step == 4
                       ? displayTimeSlot(context,barberWatch)
                       : step == 5
                           ? displayConfirm(context)
                    : Container(),
            ),
            //Button
            Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: ElevatedButton(
                            onPressed: step == 1
                                ? null
                                : ()=>context.read(currentStep).state--,
                            child: Text('Previous'),
                          )
                      ),
                      SizedBox(width: 20,
                      ),
                      Expanded(
                        child: ElevatedButton(
                          // If user not select city , button Next will be disable !
                            onPressed: (step ==1 && context.read(selectedCity).state.name == null) ||
                                (step == 2 &&
                                    context.read(selectedSalon).state.docId == null) ||
                                (step == 3 &&
                                    context.read(selectedBarber).state.docId == null) ||
                                (step == 4 &&
                                    context.read(selectedTimeSlot).state == -1)
                                ? null
                                : step == 5
                                    ? null
                                    : () => context.read(currentStep).state++,
                          child: Text('Next'),
                        )
                      ),
                    ],
                  ),
                  ),
                )
            )
          ],),
        ));
  }

  displayCityList() {
    return FutureBuilder(
        future: getCities(),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator(),);
          else{
            var cities = snapshot.data as List<CityModel>;
            if(cities == null || cities.length == 0)
              return Center(child: Text('Cannot load city list'),);
            else
              return ListView.builder(
                  itemCount: cities.length,
                  itemBuilder: (context,index){
                    return GestureDetector(onTap: ()=> context.read(selectedCity).state = cities[index],
                    child: Card(child: ListTile(
                      leading: Icon(Icons.home_work , color: Colors.blueAccent,),
                      trailing: context.read(selectedCity).state.name == cities[index].name ? Icon(Icons.check) : null,
                      title: Text('${cities[index].name}'),
                    ),),);
                  });
          }

    });
  }

  displaySalon(String cityName) {
    return FutureBuilder(
        future: getSalonByCity(cityName),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else{
            var salons = snapshot.data as List<SalonModel>;
            if(salons == null || salons.length == 0)
              return Center(
                child: Text('Cannot load Salon list'),


              );
            else
              return ListView.builder(
                  itemCount: salons.length,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: ()=>
                      context.read(selectedSalon).state = salons[index],
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.home_outlined ,
                            color: Colors.blueAccent,
                          ),
                          trailing: context.read(selectedSalon).state.docId ==
                              salons[index].docId
                              ? Icon(Icons.check)
                              : null,
                          title: Text(
                              '${salons[index].name}',
                              style: GoogleFonts.robotoMono(),

                           ),
                          subtitle: Text(
                            '${salons[index].address}',
                            style: GoogleFonts.robotoMono(fontStyle: FontStyle.italic),

                          ),
                      ),
                      ),
                    );
                  });
          }

        });

  }

  displayBarber(SalonModel salonModel) {
    return FutureBuilder(
        future: getBarbersBySalon(salonModel),
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else{
            var barbers = snapshot.data as List<BarberModel>;
            if(barbers == null || barbers.length == 0)
              return Center(
                child: Text('Barber list are empty'),


              );
            else
              return ListView.builder(
                  itemCount: barbers.length,
                  itemBuilder: (context, index){
                    return GestureDetector(
                      onTap: ()=>
                      context.read(selectedBarber).state = barbers[index],
                      child: Card(
                        child: ListTile(
                          leading: Icon(
                            Icons.person ,
                            color: Colors.blueAccent,
                          ),
                          trailing: context.read(selectedBarber).state.docId ==
                              barbers[index].docId
                              ? Icon(Icons.check)
                              : null,
                          title: Text(
                            '${barbers[index].name}',
                            style: GoogleFonts.robotoMono(),

                          ),
                          subtitle: RatingBar.builder(
                            itemSize: 16,
                            allowHalfRating: true,
                            initialRating: barbers[index].rating,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            //onRatingUpdate: (value){}, null
                            ignoreGestures: true,
                            itemBuilder: (context,_) => Icon(Icons.star , color: Colors.amber[400],),
                            itemPadding: const EdgeInsets.all(4),

                          ),
                        ),
                      ),
                    );
                  });
          }

        });
  }

  displayTimeSlot(BuildContext context, BarberModel barberModel) {
    var now = context.read(selectedDate).state;
    return Column(
      children: [
        Container(
          color: Color(0xFF008577),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(children: [
                        Text('${DateFormat.MMMM().format(now)}',style: GoogleFonts.robotoMono(color: Colors.white54),),
                        Text('${now.day}',style: GoogleFonts.robotoMono(color: Colors.white , fontWeight: FontWeight.bold,fontSize: 22)),
                        Text('${DateFormat.EEEE().format(now)}',style: GoogleFonts.robotoMono(color: Colors.white54),),
                      ],),),)),
              GestureDetector(onTap: (){
                DatePicker.showDatePicker(context,
                    showTitleActions: true,
                    minTime: DateTime.now(), // Fix can't select current date
                    maxTime: now.add(Duration(days: 31)),
                    onConfirm: (date) => context.read(selectedDate).state = date); // next time you can choose is 31 days next
              },child: Padding(
                padding: const EdgeInsets.all(8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Icon(Icons.calendar_today,color: Colors.white,),
                ),
              ),)
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder(
            future: getMaxAvailableTimeSlot(context.read(selectedDate).state),
            builder: (context,snapshot){
              if(snapshot.connectionState == ConnectionState.waiting)
                return Center(child: CircularProgressIndicator(),);
              else{
                var maxTimeSlot = snapshot.data as int;
                return FutureBuilder(
                  future: getTimeSlotOfBarber(
                    barberModel,
                    DateFormat('dd_MM_yyyy')
                        .format(context.read(selectedDate).state),),
                  builder: (context,snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting)
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    else{
                      var listTimeSlot = snapshot.data as List<int>;
                      return GridView.builder(
                          itemCount: TIME_SLOT.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3
                          ),
                          itemBuilder: (context,index)=> GestureDetector(
                                onTap:maxTimeSlot > index || listTimeSlot.contains(index)
                                    ? null
                                    : () {
                                  context.read(selectedTime).state =
                                      TIME_SLOT.elementAt(index);
                                  context.read(selectedTimeSlot).state = index;
                                },
                                child: Card(
                                  color:  listTimeSlot.contains(index)
                                      ? Colors.redAccent[200] : maxTimeSlot > index
                                      ? Colors.blueGrey[300] : context.read(selectedTime).state ==
                                      TIME_SLOT.elementAt(index)
                                      ? Colors.teal[200]
                                      : Colors.white,
                                  child: GridTile(
                                    child: Center(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text('${TIME_SLOT.elementAt(index)}'),
                                          Text( listTimeSlot.contains(index)
                                                  ? 'Full'
                                              : maxTimeSlot > index
                                                  ? 'Not Available'
                                                  :'Available')
                                        ],
                                      ),
                                    ),
                                    header:  context.read(selectedTime).state ==
                                        TIME_SLOT.elementAt(index) ? Icon(Icons.check) : null,
                                  ),),
                              ));
                    }
                  },
                );
              }
            },
          ) ,
        )

      ],
    );

  }

  confirmBooking(BuildContext context) {
      var hour = context
          .read(selectedTime)
          .state.length <= 10
          ? int.parse(context
          .read(selectedTime)
          .state.split(':')[0]
          .substring(0,1)) :

      int.parse(context
          .read(selectedTime)
          .state
          .split(':')[0]
          .substring(0,2)); // hour
       // minutes
      var minutes = context
        .read(selectedTime)
        .state.length <= 10 ?
      int.parse(context.read(selectedTime).state.split(':')[1].substring(0,1)) :

      int.parse(context.read(selectedTime).state.split(':')[1].substring(0,2)); // hour

      var timeStamp = DateTime(
      context.read(selectedDate).state.year,
      context.read(selectedDate).state.month,
      context.read(selectedDate).state.day,
          hour , // hour
          minutes //minutes
    ).millisecondsSinceEpoch;

      //Create booking model
      var bookingModel = BookingModel(
          barberId : context.read(selectedBarber).state.docId,
          barberName : context.read(selectedBarber).state.name,
          cityBook : context.read(selectedCity).state.name,
          customerId : FirebaseAuth.instance.currentUser.uid,
          customerName : context.read(userInformation).state.name,
          customerPhone : FirebaseAuth.instance.currentUser.phoneNumber,
          done : false,
          salonAddress : context.read(selectedSalon).state.address,
          salonId : context.read(selectedSalon).state.docId,
          salonName : context.read(selectedSalon).state.name,
          slot :context.read(selectedTimeSlot).state,
          timeStamp : timeStamp,
          time : '${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}'
      );

      



    var batch = FirebaseFirestore.instance.batch();

    DocumentReference barberBooking = context
        .read(selectedBarber)
        .state
        .reference
        .collection('${DateFormat('dd_MM_yyyy')
        .format(context.read(selectedDate).state)}')
        .doc(context.read(selectedTimeSlot)
        .state.toString());
    DocumentReference userBooking = FirebaseFirestore.instance.collection('user')
    .doc(FirebaseAuth.instance.currentUser.phoneNumber)
    .collection('Booking_${FirebaseAuth.instance.currentUser.uid}') // For secure info
    .doc('${context.read(selectedBarber).state.docId}_${DateFormat('dd_MM_yyyy')
        .format(context.read(selectedDate).state)}');

    // Set for batch
    batch.set(barberBooking, bookingModel.toJson());
    batch.set(userBooking, bookingModel.toJson());
    batch.commit().then((value) {

      Navigator.of(context).pop();
      ScaffoldMessenger.of(scaffoldKey.currentContext)
          .showSnackBar(SnackBar(content: Text('Booking successfully'),
      ));
      // Reset value
      context.read(selectedDate).state = DateTime.now();
      context.read(selectedBarber).state = BarberModel();
      context.read(selectedCity).state = CityModel();
      context.read(selectedSalon).state = SalonModel();
      context.read(currentStep).state = 1;
      context.read(selectedTime).state = '';
      context.read(selectedTimeSlot).state = -1;

      //Create Event
      final event = Event(
          title : 'Barner Appoiment',
          description: 'Barber appoiment ${context.read(selectedTime).state} - '
              '${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}',
          location: '${context.read(selectedSalon).state.address}',
          startDate: DateTime(
              context.read(selectedDate).state.year,
              context.read(selectedDate).state.month,
              context.read(selectedDate).state.day,
              hour,
              minutes
          ),
          endDate: DateTime(
              context.read(selectedDate).state.year,
              context.read(selectedDate).state.month,
              context.read(selectedDate).state.day,
              hour,
              minutes + 30
          ),
          iosParams: IOSParams(reminder: Duration(minutes: 30)),
          androidParams: AndroidParams(emailInvites: [])
      );
      Add2Calendar.addEvent2Cal(event).then((value) {});

    });








  }

  displayConfirm(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Padding(padding: const EdgeInsets.all(24),
          child: Image.asset('assets/images/logo.png'),
        ),),
        Expanded(
            flex: 3,
            child: Container(
          width: MediaQuery.of(context).size.width,
          child: Card(child: Padding(padding: const EdgeInsets.all(16),child:
            Column(
              children: [
                Text('Thank you for booking our services'.toUpperCase(),
                style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),),
                Text('Booking Information'.toUpperCase(),
                  style: GoogleFonts.robotoMono(),),
                Divider(thickness: 1,),
                Row(children: [
                  Icon(Icons.calendar_today),
                  SizedBox(width: 20,),
                  Text('${context.read(selectedTime).state} - ${DateFormat('dd/MM/yyyy').format(context.read(selectedDate).state)}'.toUpperCase())
                ],),
                SizedBox(height: 10,),
                Row(children: [
                  Icon(Icons.person),
                  SizedBox(width: 20,),
                  Text('${context.read(selectedBarber).state.name} '.toUpperCase())
                ],),
                SizedBox(height: 10,),
                Divider(thickness: 1,),
                Row(children: [
                  Icon(Icons.home),
                  SizedBox(width: 20,),
                  Text('${context.read(selectedSalon).state.name} '.toUpperCase(),style: GoogleFonts.robotoMono(),)
                ],),
                SizedBox(height: 10,),
                Row(children: [
                  Icon(Icons.location_on),
                  SizedBox(width: 20,),
                  Text('${context.read(selectedSalon).state.address} '.toUpperCase())
                ],),
                SizedBox(height: 8,),
                ElevatedButton(
                  onPressed: ()=> confirmBooking(context),
                  child: Text('Confirm'),
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black26)
                  ),
                )

              ],
            )
            ,),),
        ))
      ],
    );
  }

}