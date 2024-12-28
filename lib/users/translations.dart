class Translations {
  static Map<String, Map<String, String>> localizedStrings = {
    'en': {
      'title': 'Doctor Appointment Assistant App',
      'selectLanguage': 'Select Language',
      'makeAppointment': 'Make Appointment',
      'askAnyQuestions': 'Ask Any Question About Health',
      'checkAppointment': 'Check Scheduled Appointment',
      'rescheduleCancel': 'Reschedule or Cancel',
      'bmiCalculation': 'BMI Calculation',
      'doctorList': 'Doctor List',
      'callEmergency': 'Call Emergency',
      'hospitalNearMe': 'Hospitals Near Me',
      'logout': 'Logout',
      'No Upcoming Appointments': 'No Upcoming Appointments',
      'Next Appointment': 'Next Appointment',
      'with': 'with',
      'at': 'at',
      'on': 'on',
      'Serial No': 'Serial No',
      'Now Running Serial No': 'Now Running Serial No',
      'View Appointment': 'View Appointment',
    },
    'bn': {
      'title': 'ডাক্তার অ্যাপয়েন্টমেন্ট সহকারী অ্যাপ',
      'selectLanguage': 'ভাষা নির্বাচন করুন',
      'makeAppointment': 'অ্যাপয়েন্টমেন্ট করুন',
      'askAnyQuestions': 'স্বাস্থ্য সম্পর্কিত কোনো প্রশ্ন জিজ্ঞাসা করুন',
      'checkAppointment': 'তফসিল অ্যাপয়েন্টমেন্ট চেক করুন',
      'rescheduleCancel': 'পুনরায় নির্ধারণ বা বাতিল করুন',
      'bmiCalculation': 'বিএমআই গণনা',
      'doctorList': 'ডাক্তার তালিকা',
      'callEmergency': 'জরুরি কল করুন',
      'hospitalNearMe': 'আমার কাছাকাছি হাসপাতাল',
      'logout': 'লগআউট',
      'No Upcoming Appointments': 'কোনো আসন্ন অ্যাপয়েন্টমেন্ট নেই',
      'Next Appointment': 'পরবর্তী অ্যাপয়েন্টমেন্ট',
      'with': 'সঙ্গে',
      'at': 'এ',
      'on': 'তারিখে',
      'Serial No': 'সিরিয়াল নম্বর',
      'Now Running Serial No': 'এখন সিরিয়াল নম্বর চলছে',
      'View Appointment': 'অ্যাপয়েন্টমেন্ট দেখুন',
    },
  };

  static String getTranslation(String key, String languageCode) {
    return localizedStrings[languageCode]?[key] ?? key;
  }
}
