<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
      
      <!-- Header -->
      <div class="mb-8">
        <h1 class="text-2xl font-semibold text-gray-800">
          Monitor Dashboard
        </h1>
        <p class="text-sm text-gray-500">
          ตรวจสอบ System & API Logs 
        </p>
      </div>

      <!-- ALERT -->
      <div v-if="summary.highError"
           class="mb-6 p-4 bg-red-100 text-red-700 rounded-md">
         พบ Error จำนวนมากในช่วง 5 นาทีล่าสุด ({{ summary.errorCount }} ครั้ง)
      </div>

      <!-- Summary Cards -->
      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">

        <div class="bg-white border rounded-lg p-4 shadow-sm">
          <p class="text-sm text-gray-500">Total Requests</p>
          <p class="text-2xl font-bold text-blue-600">
            {{ summary.total }}
          </p>
        </div>

        <div class="bg-white border rounded-lg p-4 shadow-sm">
          <p class="text-sm text-gray-500">Errors (5 min)</p>
          <p class="text-2xl font-bold text-red-600">
            {{ summary.errorCount }}
          </p>
        </div>

        <div class="bg-white border rounded-lg p-4 shadow-sm">
          <p class="text-sm text-gray-500">Avg Response Time</p>
          <p class="text-2xl font-bold text-yellow-600">
            {{ summary.avgResponse }} ms
          </p>
        </div>

      </div>

      <!-- Log Table -->
      <div class="bg-white border border-gray-300 rounded-lg shadow-sm">

        <div class="px-4 py-4 border-b border-gray-200">
          <h2 class="font-medium text-gray-800">
            System Logs (ล่าสุด 100 รายการ)
          </h2>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full text-sm text-left">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-2">Time</th>
                <th class="px-4 py-2">Method</th>
                <th class="px-4 py-2">Endpoint</th>
                <th class="px-4 py-2">Status</th>
                <th class="px-4 py-2">Response</th>
                <th class="px-4 py-2">Level</th>
              </tr>
            </thead>

            <tbody>
              <tr v-for="log in logs"
                  :key="log.id"
                  class="border-b hover:bg-gray-50">

                <td class="px-4 py-2">
                  {{ formatDate(log.createdAt) }}
                </td>

                <td class="px-4 py-2">
                  {{ log.method }}
                </td>

                <td class="px-4 py-2">
                  {{ log.endpoint }}
                </td>

                <td class="px-4 py-2">
                  {{ log.statusCode }}
                </td>

                <td class="px-4 py-2">
                  {{ log.responseTime }} ms
                </td>

                <td class="px-4 py-2">
                  <span
                    :class="levelClass(log.level)"
                    class="px-2 py-1 text-xs rounded-full">
                    {{ log.level }}
                  </span>
                </td>

              </tr>

              <tr v-if="logs.length === 0">
                <td colspan="6"
                    class="px-4 py-6 text-center text-gray-500">
                  ไม่พบข้อมูล Log
                </td>
              </tr>

            </tbody>
          </table>
        </div>

      </div>

    </main>
  </div>
</template>




<script setup>
import { ref, onMounted } from 'vue'
import { useRuntimeConfig } from '#app'
import dayjs from 'dayjs'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'

definePageMeta({ middleware: ['admin-auth'] })

const logs = ref([])
const summary = ref({
  total: 0,
  errorCount: 0,
  avgResponse: 0,
  highError: false
})

function formatDate(iso) {
  if (!iso) return '-'
  return dayjs(iso).format('D MMM YYYY HH:mm:ss')
}

function levelClass(level) {
  if (level === 'ERROR') return 'bg-red-100 text-red-700'
  if (level === 'WARN') return 'bg-yellow-100 text-yellow-700'
  return 'bg-green-100 text-green-700'
}

function getAuthHeaders() {
  const token = localStorage.getItem('token')
  return token
    ? { Authorization: `Bearer ${token}` }
    : {}
}

async function fetchLogs() {
  const config = useRuntimeConfig()

  try {
    logs.value = await $fetch('/monitor/logs', {
      baseURL: config.public.apiBase,
      headers: getAuthHeaders()
    })
  } catch (error) {
    console.error('Fetch logs error:', error)
  }
}

async function fetchSummary() {
  const config = useRuntimeConfig()

  try {
    summary.value = await $fetch('/monitor/logs/summary', {
      baseURL: config.public.apiBase,
      headers: getAuthHeaders()
    })
  } catch (error) {
    console.error('Fetch summary error:', error)
  }
}

onMounted(async () => {
  await fetchLogs()
  await fetchSummary()
})
</script>
