<template>
  <div>
    <AdminHeader />
    <AdminSidebar />

    <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
      <div class="mb-8">
        <h1 class="text-2xl font-semibold text-gray-800">Monitor Dashboard</h1>
        <p class="text-sm text-gray-500">ตรวจสอบ System & API Logs</p>
      </div>

      <div
        v-if="summary.highError"
        class="mb-6 p-4 bg-red-100 text-red-700 rounded-md"
      >
        พบ Error จำนวนมากในช่วง 5 นาทีล่าสุด ({{ summary.errorCount }} ครั้ง)
      </div>

      <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
        <div class="bg-white border rounded-lg p-4 shadow-sm">
          <p class="text-sm text-gray-500">Total Requests</p>
          <p class="text-2xl font-bold text-black">
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
          <p class="text-2xl font-bold text-black">
            {{ summary.avgResponse }} ms
          </p>
        </div>
      </div>

      <div class="mb-4 border-b border-gray-200">
        <nav class="flex space-x-6">
          <button
            v-for="tab in tabs"
            :key="tab"
            @click="changeTab(tab)"
            :class="[
              'pb-2 text-sm font-medium',
              activeTab === tab
                ? 'border-b-2 border-black text-black'
                : 'text-gray-500 hover:text-black',
            ]"
          >
            {{ tab }}
          </button>
        </nav>
      </div>

      <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
        <div
          class="px-4 py-4 border-b border-gray-200 flex justify-between items-center"
        >
          <h2 class="font-medium text-gray-800">
            {{ activeTab }} (ล่าสุด 100 รายการ)
          </h2>

          <div class="flex items-center gap-3">
            <input
              type="text"
              v-model="searchQuery"
              @keyup.enter="fetchLogs"
              placeholder="กด Enter เพื่อค้นหา"
              class="border px-3 py-2 rounded-md text-sm w-[200px]"
            />

            <select
              v-if="activeTab === 'SystemLog'"
              v-model="selectedLevel"
              @change="fetchLogs"
              class="border px-3 py-2 rounded-md text-sm"
            >
              <option value="ALL">All Levels</option>
              <option value="INFO">INFO</option>
              <option value="WARN">WARN</option>
              <option value="ERROR">ERROR</option>
            </select>

            <input
              type="date"
              v-model="selectedDate"
              @change="fetchLogs"
              class="border px-3 py-2 rounded-md text-sm"
            />

            <select 
              v-model="selectedFormat" 
              class="border px-3 py-2 rounded-md text-sm bg-gray-50 font-medium"
            >
              <option value="CSV">CSV</option>
              <option value="JSON">JSON</option>
              <option value="PDF">PDF</option>
            </select>

            <button 
              @click="handleAdminExport" 
              :disabled="isExporting"
              class="flex items-center gap-2 border px-4 py-2 rounded-md text-sm font-medium transition"
              :class="isExporting ? 'bg-gray-300 text-gray-500 cursor-not-allowed' : 'bg-black text-white hover:bg-gray-800'"
            >
              <svg v-if="isExporting" class="animate-spin h-4 w-4 text-gray-500" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
                <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v8H4z"></path>
              </svg>
              <svg v-else class="h-4 w-4" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"></path>
              </svg>
              {{ isExporting ? 'กำลังเตรียมไฟล์...' : `Export ${selectedFormat}` }}
            </button>

          </div>
        </div>

        <div class="overflow-x-auto">
          <table class="min-w-full table-fixed text-sm text-left">
            <thead class="bg-gray-50">
              <tr>
                <th class="px-4 py-2 w-[180px]">Time</th>

                <template v-if="activeTab === 'AuditLog'">
                  <th class="px-4 py-2 w-[120px]">User</th>
                  <th class="px-4 py-2 w-[100px]">Role</th>
                  <th class="px-4 py-2 w-[200px]">Action</th>
                  <th class="px-4 py-2 w-[150px]">Entity</th>
                  <th class="px-4 py-2 w-[120px]">Entity ID</th>
                  <th class="px-4 py-2 w-[150px]">IP Address</th>
                  <th class="px-4 py-2 w-[200px]">User Agent</th>
                </template>

                <template v-else-if="activeTab === 'SystemLog'">
                  <th class="px-4 py-2 w-[80px]">Level</th>
                  <th class="px-4 py-2 w-[120px]">Request ID</th>
                  <th class="px-4 py-2 w-[80px]">Method</th>
                  <th class="px-4 py-2 w-[250px]">Path</th>
                  <th class="px-4 py-2 w-[80px]">Status</th>
                  <th class="px-4 py-2 w-[100px]">Duration</th>
                  <th class="px-4 py-2 w-[120px]">User</th>
                  <th class="px-4 py-2 w-[140px]">IP</th>
                  <th class="px-4 py-2 w-[200px]">User Agent</th>
                  <th class="px-4 py-2 w-[200px]">Error</th>
                  <th class="px-4 py-2 w-[200px]">Metadata</th>
                </template>

                <template v-else>
                  <th class="px-4 py-2 w-[120px]">User</th>
                  <th class="px-4 py-2 w-[150px]">Login Time</th>
                  <th class="px-4 py-2 w-[150px]">Logout Time</th>
                  <th class="px-4 py-2 w-[140px]">IP Address</th>
                  <th class="px-4 py-2 w-[200px]">User Agent</th>
                  <th class="px-4 py-2 w-[160px]">Session ID</th>
                </template>
              </tr>
            </thead>

            <tbody>
              <tr
                v-for="log in logs"
                :key="log.id"
                class="border-b odd:bg-white even:bg-gray-50 hover:bg-gray-100"
              >
                <td class="px-4 py-2">
                  {{ formatDate(log.createdAt) }}
                </td>

                <template v-if="activeTab === 'AuditLog'">
                  <td class="px-4 py-2 font-medium">
                    {{ log.userId || "-" }}
                  </td>

                  <td class="px-4 py-2">
                    {{ log.role || "-" }}
                  </td>

                  <td class="px-4 py-2">
                    {{ log.action }}
                  </td>

                  <td class="px-4 py-2">
                    {{ log.entity || "-" }}
                  </td>

                  <td class="px-4 py-2">
                    {{ log.entityId || "-" }}
                  </td>

                  <td class="px-4 py-2">
                    {{ log.ipAddress || "-" }}
                  </td>

                  <td class="px-4 py-2 truncate" :title="log.userAgent">
                    {{ log.userAgent || "-" }}
                  </td>

                  <td
                    class="px-4 py-2 truncate"
                    :title="JSON.stringify(log.metadata)"
                  >
                    {{ log.metadata ? JSON.stringify(log.metadata) : "-" }}
                  </td>
                </template>

                <template v-else-if="activeTab === 'SystemLog'">
                  <td class="px-4 py-2">
                    <span
                      class="px-2 py-1 text-xs font-semibold rounded"
                      :class="levelClass(log.level)"
                    >
                      {{ log.level }}
                    </span>
                  </td>

                  <td class="px-4 py-2">{{ log.requestId || "-" }}</td>
                  <td class="px-4 py-2">{{ log.method || "-" }}</td>

                  <td class="px-4 py-2 truncate" :title="log.path">
                    {{ log.path || "-" }}
                  </td>

                  <td class="px-4 py-2">{{ log.statusCode || "-" }}</td>
                  <td class="px-4 py-2">
                    {{ log.duration ? log.duration + " ms" : "-" }}
                  </td>

                  <td class="px-4 py-2">{{ log.userId || "-" }}</td>
                  <td class="px-4 py-2">{{ log.ipAddress || "-" }}</td>

                  <td class="px-4 py-2 truncate" :title="log.userAgent">
                    {{ log.userAgent || "-" }}
                  </td>

                  <td
                    class="px-4 py-2 truncate"
                    :title="JSON.stringify(log.error)"
                  >
                    {{ log.error ? JSON.stringify(log.error) : "-" }}
                  </td>

                  <td
                    class="px-4 py-2 truncate"
                    :title="JSON.stringify(log.metadata)"
                  >
                    {{ log.metadata ? JSON.stringify(log.metadata) : "-" }}
                  </td>
                </template>

                <template v-else>
                  <td class="px-4 py-2">{{ log.userId }}</td>

                  <td class="px-4 py-2">
                    {{ formatDate(log.loginTime) }}
                  </td>

                  <td class="px-4 py-2">
                    {{ log.logoutTime ? formatDate(log.logoutTime) : "-" }}
                  </td>

                  <td class="px-4 py-2">{{ log.ipAddress }}</td>

                  <td class="px-4 py-2 truncate" :title="log.userAgent">
                    {{ log.userAgent || "-" }}
                  </td>

                  <td class="px-4 py-2">
                    {{ log.sessionId || "-" }}
                  </td>
                </template>
              </tr>

              <tr v-if="logs.length === 0">
                <td
                  :colspan="
                    activeTab === 'AuditLog'
                      ? 8
                      : activeTab === 'SystemLog'
                        ? 12
                        : 7
                  "
                  class="px-4 py-6 text-center text-gray-500"
                >
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
import { ref, onMounted, onUnmounted } from "vue";
import { useRuntimeConfig } from "#app";
import dayjs from "dayjs";
import AdminHeader from "~/components/admin/AdminHeader.vue";
import AdminSidebar from "~/components/admin/AdminSidebar.vue";

definePageMeta({ middleware: ["admin-auth"] });

const selectedDate = ref("");
const searchQuery = ref(""); // เพิ่ม State สำหรับเก็บคำค้นหา
const logs = ref([]);
const selectedLevel = ref("ALL");
const tabs = ["AuditLog", "SystemLog", "AccessLog"];
const activeTab = ref("AuditLog");

const isExporting = ref(false);
const selectedFormat = ref("CSV");

function changeTab(tab) {
  activeTab.value = tab;
  searchQuery.value = ""; // ล้างคำค้นหาเมื่อเปลี่ยนแท็บ
  fetchLogs();
}

const summary = ref({
  total: 0,
  errorCount: 0,
  avgResponse: 0,
  highError: false,
});

const config = useRuntimeConfig();
function formatDate(date) {
  if (!date) return "-";
  return dayjs(date).format("D MMM YYYY HH:mm:ss");
}

function levelClass(level) {
  switch (level) {
    case "ERROR":
      return "bg-red-100 text-red-700";
    case "WARN":
      return "bg-yellow-100 text-yellow-700";
    default:
      return "bg-green-100 text-green-700";
  }
}

function getAuthHeaders() {
  const token = useCookie("token").value;
  //console.log("Token value:", token);

  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function fetchLogs() {
  try {
    const data = await $fetch("/monitor/logs", {
      baseURL: config.public.apiBase,
      headers: getAuthHeaders(),
      query: {
        level: selectedLevel.value,
        type: activeTab.value,
        date: selectedDate.value || undefined,
        search: searchQuery.value || undefined, // ส่งค่าการค้นหาไปที่ Backend
      },
    });

    logs.value = data;
  } catch (error) {
    console.error("Fetch logs error:", error);
  }
}

async function fetchSummary() {
  try {
    const data = await $fetch("/monitor/logs/summary", {
      baseURL: config.public.apiBase,
      headers: getAuthHeaders(),
    });

    summary.value = data;
  } catch (error) {
    console.error("Fetch summary error:", error);
  }
}

async function handleAdminExport() {
  if (isExporting.value) return;
  isExporting.value = true;
  
  try {
    let dateFromFilter = undefined;
    let dateToFilter = undefined;

    // 2. เช็กว่า User ได้เลือกวันที่ในหน้าจอไหม
    if (selectedDate.value) {
      dateFromFilter = `${selectedDate.value}T00:00:00.000Z`;
      dateToFilter = `${selectedDate.value}T23:59:59.999Z`;
    }

    const reqResponse = await $fetch("/logs/exports", {
      method: "POST",
      baseURL: config.public.apiBase,
      headers: getAuthHeaders(),
      body: {
        logType: activeTab.value,
        format: selectedFormat.value,
        filters: {
          q: searchQuery.value || undefined, 
          level: selectedLevel.value !== "ALL" ? selectedLevel.value : undefined,
          dateFrom: dateFromFilter,
          dateTo: dateToFilter
        }
      }
    });

    if (reqResponse.success && reqResponse.data?.id) {
      const exportId = reqResponse.data.id;
      
      const blob = await $fetch(`/logs/exports/${exportId}/download`, {
        baseURL: config.public.apiBase,
        headers: getAuthHeaders(),
        responseType: 'blob'
      });

      let extension = "csv";
      if (selectedFormat.value === "JSON") extension = "json";
      if (selectedFormat.value === "PDF") extension = "pdf";

      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `${activeTab.value}_Export_${dayjs().format('YYYYMMDD_HHmm')}.${extension}`;
      document.body.appendChild(a);
      a.click();
      window.URL.revokeObjectURL(url);
      a.remove();
    }
  } catch (error) {
    console.error("Export Error:", error);
    alert("เกิดข้อผิดพลาดในการ Export Log");
  } finally {
    isExporting.value = false;
  }
}

let interval;

onMounted(async () => {
  await fetchLogs();
  await fetchSummary();

  interval = setInterval(() => {
    fetchSummary();
  }, 10000); 
});

onUnmounted(() => {
  clearInterval(interval);
});
</script>
