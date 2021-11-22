package app.akiho.calendar

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.util.Calendar
import com.google.firebase.auth.ktx.auth
import com.google.firebase.ktx.Firebase
import com.google.firebase.firestore.ktx.firestore
import android.util.Log
import android.view.View

class Schedule(val name: String)

class WidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        val calendar = Calendar.getInstance()
        val weekName = arrayOf("日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日")
        val week: String = weekName[calendar.get(Calendar.DAY_OF_WEEK) - 1]
        val year: String = calendar.get(Calendar.YEAR).toString()
        val month: String = (calendar.get(Calendar.MONTH) + 1).toString().padStart(2, '0')
        val day: String = calendar.get(Calendar.DATE).toString().padStart(2, '0')

        val user = Firebase.auth.currentUser
        Firebase.firestore.collection("schedule/${user!!.uid}/${year}-${month}")
            .whereEqualTo("dateYMD", "${year}-${month}-${day}")
            .orderBy("createdAtTimestamp")
            .limit(2)
            .get()
            .addOnSuccessListener { result ->
                val schedules: List<Schedule> = result.documents.map { Schedule(name = it.data!!["name"] as String) }

                appWidgetIds.forEach { widgetId ->
                    val views = RemoteViews(context.packageName, R.layout.widget).apply {
                        val pendingIntent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
                        setOnClickPendingIntent(R.id.widget_container, pendingIntent)

                        setTextViewText(R.id.widget_week, week)
                        setTextViewText(R.id.widget_day, day)

                        setViewVisibility(R.id.schedule_1, View.INVISIBLE)
                        setViewVisibility(R.id.schedule_2, View.INVISIBLE)
                        if (schedules.isNotEmpty()) {
                            setViewVisibility(R.id.schedule_1, View.VISIBLE)
                            setTextViewText(R.id.schedule_1, schedules.first().name)
                        }
                        if (schedules.size > 1) {
                            setViewVisibility(R.id.schedule_2, View.VISIBLE)
                            setTextViewText(R.id.schedule_2, schedules[1].name)
                        }
                    }

                    appWidgetManager.updateAppWidget(widgetId, views)
                }
            }
            .addOnFailureListener { exception ->
                Log.w("Log", "Error getting documents.", exception)
            }
    }
}