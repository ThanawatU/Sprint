<template>
    <div class="">
        <AdminHeader />
        <AdminSidebar />

        <!-- Main Content -->
        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">
            <!-- Page Title -->
            <div class="mx-auto max-w-8xl">
                <!-- Title -->
                <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                    <div class="flex items-center gap-3">
                        <h1 class="text-2xl font-semibold text-gray-800">Report Management</h1>
                    </div>

                    <!-- Quick Search -->
                    <div class="flex items-center gap-2">
                        <input v-model.trim="filters.q" @keyup.enter="applyFilters" type="text"
                            placeholder="ค้นหา Trip ID"
                            class="max-w-full px-3 py-2 border border-gray-300 rounded-md w-72 focus:outline-none focus:ring-2 focus:ring-blue-500" />
                        <button @click="applyFilters"
                            class="px-4 py-2 text-white bg-blue-600 rounded-md cursor-pointer hover:bg-blue-700">
                            ค้นหา
                        </button>
                    </div>
                </div>

                <div class="grid grid-cols-1 gap-4 mb-6 sm:grid-cols-2 lg:grid-cols-2">

                <!-- Total Reports -->
                <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
                <p class="text-sm text-gray-500">Total Reports</p>
                <p class="text-3xl font-bold text-gray-900 mt-2">
                {{ stats.total }}
                </p>
                </div>

                <!-- Closed Today -->
                <div class="bg-white border border-gray-200 rounded-lg shadow-sm p-6">
                <p class="text-sm text-gray-500">Resolved Today</p>
                <p class="text-3xl font-bold text-green-600 mt-2">
                {{ stats.resolvedToday }}
                </p>
                </div>

                </div>

                <!-- Status Distribution Bar -->
                <div class="bg-white border border-gray-300 rounded-lg shadow-sm mb-6 p-6">
                    <h3 class="text-lg font-semibold text-gray-800 mb-4">สถานะ Report</h3>
                    <div class="grid grid-cols-2 gap-4 sm:grid-cols-3 lg:grid-cols-4">
                        <div v-for="status in statusList"
                        :key="status.value"
                        class="p-4 border border-gray-200 rounded-lg hover:shadow-md transition-shadow cursor-pointer"
                        @click="filterByStatus(status.value)"
                        >
                            <p class="text-xs font-medium text-gray-600 mb-1">
                                {{ status.label }}
                            </p>
                            <p class="text-2xl font-bold" :class="status.color">
                                {{ stats.byStatus[status.value] || 0 }}
                            </p>
                        </div>
                    </div>
                </div>

                <!-- Filters -->
                <div class="mb-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                    <div class="grid grid-cols-1 gap-3 px-4 py-4 sm:px-6 lg:grid-cols-3">
                        <!-- Status Filter -->
                        <div>
                            <label class="block mb-1 text-xs font-medium text-gray-600">สถานะ</label>
                            <select v-model="filters.status"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500">
                                <option value="">ทั้งหมด</option>
                                <option value="PENDING">PENDING</option>
                                <option value="UNDER_REVIEW">UNDER_REVIEW</option>
                                <option value="RESOLVED">RESOLVED</option>
                                <option value="REJECTED">REJECTED</option>
                            </select>
                        </div>

                        <!-- Sort -->
                        <div>
                            <label class="block mb-1 text-xs font-medium text-gray-600">เรียงตาม</label>
                            <select
                                v-model="filters.sort"
                                class="w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500"
                            >
                                <option value="">ค่าเริ่มต้น (Report ล่าสุด)</option>
                                <option value="lastReportAt:desc">Report ล่าสุด → เก่าสุด</option>
                                <option value="lastReportAt:asc">Report เก่าสุด → ล่าสุด</option>
                            </select>
                        </div>

                        <!-- Actions -->
                        <div class="flex items-end justify-end gap-2">
                            <button @click="clearFilters"
                                class="px-3 py-2 text-gray-700 border border-gray-300 rounded-md cursor-pointer hover:bg-gray-50">
                                ล้างตัวกรอง
                            </button>
                            <button @click="applyFilters"
                                class="px-4 py-2 text-white bg-blue-600 rounded-md cursor-pointer hover:bg-blue-700">
                                ใช้ตัวกรอง
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Reports Table Card -->
                <div class="bg-white border border-gray-300 rounded-lg shadow-sm">
                    <div class="flex items-center justify-between px-4 py-4 border-b border-gray-200 sm:px-6">
                        <div class="text-sm text-gray-600">
                            ทั้งหมด {{ filteredTrips.length }} รายการ
                        </div>
                    </div>

                    <!-- Loading / Error -->
                    <div v-if="isLoading" class="p-8 text-center text-gray-500">กำลังโหลดข้อมูล...</div>
                    <div v-else-if="loadError" class="p-8 text-center text-red-600">
                        {{ loadError }}
                    </div>

                    <!-- Table -->
                    <div v-else class="overflow-x-auto">
                        <table class="min-w-full divide-y divide-gray-200">
                            <thead class="bg-gray-50">
                                <tr>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Trip ID</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Total Reports</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Pending</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Under Review</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Resolved</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Rejected</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Latest Report</th>
                                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">Action</th>
                                </tr>
                            </thead>
                            <tbody class="bg-white divide-y divide-gray-200">
                                <tr v-for="trip in filteredTrips" :key="trip.routeId" class="hover:bg-gray-50">
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="text-sm font-medium text-gray-900">
                                            {{ trip.routeId || '-' }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="text-sm font-medium text-gray-900">
                                            {{ trip.reportCount || '-' }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="text-sm font-medium text-gray-900">
                                            {{ trip.statusBreakdown?.PENDING || 0 }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="text-sm font-medium text-gray-900">
                                            {{ trip.statusBreakdown.UNDER_REVIEW || '0' }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="text-sm font-medium text-gray-900">
                                            {{ trip.statusBreakdown.RESOLVED || '0' }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="text-sm font-medium text-gray-900">
                                            {{ trip.statusBreakdown.REJECTED || '0' }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="text-sm font-medium text-gray-900">
                                            {{ formatDate(trip.lastReportAt) }}
                                        </div>
                                    </td>
                                    <td class="px-4 py-3 text-sm text-gray-700">
                                        <div class="flex items-center gap-2">
                                            <button @click="navigateTo(`/admin/reports-dashboard/trip/${trip.routeId}`)"
                                                class="p-2 text-gray-500 transition-colors cursor-pointer hover:text-blue-600"
                                                title="ดูรายละเอียด" aria-label="ดูรายละเอียด">
                                                <i class="text-lg fa-regular fa-eye"></i>
                                            </button>
                                            <!-- <button @click="onExportReport(report)"
                                                class="p-2 text-gray-500 transition-colors cursor-pointer hover:text-green-600"
                                                title="Export" aria-label="Export">
                                                <i class="text-lg fa-solid fa-download"></i>
                                            </button> -->
                                        </div>
                                    </td>
                                </tr>

                                <tr v-if="!trips.length">
                                    <td colspan="8" class="px-4 py-10 text-center text-gray-500">
                                        ไม่มีข้อมูล Report
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                    </div>

                    <!-- Pagination -->
                    <div
                        class="flex flex-col gap-3 px-4 py-4 border-t border-gray-200 sm:px-6 sm:flex-row sm:items-center sm:justify-between">
                        <div class="flex flex-wrap items-center gap-3 text-sm">
                            <div class="flex items-center gap-2">
                                <span class="text-xs text-gray-500">Limit:</span>
                                <select v-model.number="pagination.limit" @change="applyFilters"
                                    class="px-2 py-1 text-sm border border-gray-300 rounded-md focus:ring-blue-500">
                                    <option :value="10">10</option>
                                    <option :value="20">20</option>
                                    <option :value="50">50</option>
                                </select>
                            </div>
                        </div>

                        <nav class="flex items-center gap-1">
                            <button class="px-3 py-2 text-sm border rounded-md disabled:opacity-50"
                                :disabled="pagination.page <= 1 || isLoading" @click="changePage(pagination.page - 1)">
                                Previous
                            </button>

                            <template v-for="(p, idx) in pageButtons" :key="`p-${idx}-${p}`">
                                <span v-if="p === '…'" class="px-2 text-sm text-gray-500">…</span>
                                <button v-else class="px-3 py-2 text-sm border rounded-md"
                                    :class="p === pagination.page ? 'bg-blue-50 text-blue-600 border-blue-200' : 'hover:bg-gray-50'"
                                    :disabled="isLoading" @click="changePage(p)">
                                    {{ p }}
                                </button>
                            </template>

                            <button class="px-3 py-2 text-sm border rounded-md disabled:opacity-50"
                                :disabled="pagination.page >= totalPages || isLoading"
                                @click="changePage(pagination.page + 1)">
                                Next
                            </button>
                        </nav>
                    </div>
                </div>
            </div>
        </main>

        <!-- Mobile Overlay -->
        <div id="overlay" class="fixed inset-0 z-40 hidden bg-black bg-opacity-50 lg:hidden"
            @click="closeMobileSidebar"></div>
    </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, onUnmounted } from 'vue'
import { useRuntimeConfig, useCookie } from '#app'
import dayjs from 'dayjs'
import 'dayjs/locale/th'
import buddhistEra from 'dayjs/plugin/buddhistEra'
import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import { useToast } from '~/composables/useToast'

dayjs.locale('th')
dayjs.extend(buddhistEra)

definePageMeta({ middleware: ['admin-auth'] })

const { toast } = useToast()

const isLoading = ref(false)
const loadError = ref('')
const trips = ref([])

const stats = reactive({
    total: 0,
    resolvedToday : 0,
    byStatus: {
        PENDING: 0,
        UNDER_REVIEW: 0,
        RESOLVED: 0,
        REJECTED: 0
    }
})

const statusList = [
  { value: 'PENDING', label: 'Pending', color: 'text-blue-600' },
  { value: 'UNDER_REVIEW', label: 'Under Review', color: 'text-yellow-600' },
  { value: 'RESOLVED', label: 'Resolved', color: 'text-green-600' },
  { value: 'REJECTED', label: 'Rejected', color: 'text-red-600' }
]

const pagination = reactive({
    page: 1,
    limit: 20,
    total: 0,
    totalPages: 1
})

const filters = reactive({
    q: '',
    status: '',
    category: '',
    sort: ''
})

const totalPages = computed(() =>
    Math.max(1, pagination.totalPages || Math.ceil((pagination.total || 0) / (pagination.limit || 20)))
)

const pageButtons = computed(() => {
    const total = totalPages.value
    const current = pagination.page
    if (!total || total < 1) return []
    if (total <= 5) return Array.from({ length: total }, (_, i) => i + 1)
    const set = new Set([1, total, current])
    if (current - 1 > 1) set.add(current - 1)
    if (current + 1 < total) set.add(current + 1)
    const pages = Array.from(set).sort((a, b) => a - b)
    const out = []
    for (let i = 0; i < pages.length; i++) {
        if (i > 0 && pages[i] - pages[i - 1] > 1) out.push('…')
        out.push(pages[i])
    }
    return out
})

const filteredTrips = computed(() => {

    let data = [...trips.value]

    // Search Trip ID
    if (filters.q) {
        const q = filters.q.toLowerCase()

        data = data.filter(trip =>
        trip.routeId?.toLowerCase().includes(q)
        )
    }

    // Filter Status
    if (filters.status) {
        data = data.filter(trip =>
        trip.statusBreakdown?.[filters.status] > 0
        )
    }

    // Sort
    if (filters.sort) {

        const [field, order] = filters.sort.split(":")

        data.sort((a, b) => {

        const aVal = new Date(a[field] || 0)
        const bVal = new Date(b[field] || 0)

        return order === "asc"
            ? aVal - bVal
            : bVal - aVal
        })

    }

    return data

})

// function statusBadge(status) {
//     const map = {
//         FILED: 'bg-blue-100 text-blue-700',
//         UNDER_REVIEW: 'bg-yellow-100 text-yellow-700',
//         RESOLVED: 'bg-green-100 text-green-700',
//         REJECTED: 'bg-red-100 text-red-700',
//         CLOSED: 'bg-gray-100 text-gray-700'
//     }
//     return map[status] || 'bg-gray-100 text-gray-700'
// }

// function categoryBadge(category) {
//     const map = {
//         DANGEROUS_DRIVING: 'bg-red-100 text-red-700',
//         AGGRESSIVE_BEHAVIOR: 'bg-orange-100 text-orange-700',
//         HARASSMENT: 'bg-purple-100 text-purple-700',
//         NO_SHOW: 'bg-yellow-100 text-yellow-700',
//         FRAUD_OR_SCAM: 'bg-pink-100 text-pink-700',
//         OTHER: 'bg-gray-100 text-gray-700'
//     }
//     return map[category] || 'bg-gray-100 text-gray-700'
// }

// function formatStatus(status) {
//     const map = {
//         FILED: 'Filed',
//         UNDER_REVIEW: 'Under Review',
//         RESOLVED: 'Resolved',
//         REJECTED: 'Rejected',
//         CLOSED: 'Closed'
//     }
//     return map[status] || status
// }

function formatCategory(category) {
    const map = {
        DANGEROUS_DRIVING: 'Dangerous Driving',
        AGGRESSIVE_BEHAVIOR: 'Aggressive Behavior',
        HARASSMENT: 'Harassment',
        NO_SHOW: 'No Show',
        FRAUD_OR_SCAM: 'Fraud/Scam',
        OTHER: 'Other'
    }
    return map[category] || category
}

// function formatDate(iso) {
//     if (!iso) return '-'
//     return dayjs(iso).format('D MMM BBBB HH:mm')
// }

async function fetchTrips(page = 1) {

  const config = useRuntimeConfig()
  const token = useCookie('token').value

  isLoading.value = true

  try {

    const res = await $fetch('/reports/admin/trips', {
      baseURL: config.public.apiBase,

      headers: {
        Authorization: `Bearer ${token}`
      },

      query: {
        page,
        limit: pagination.limit,
        q: filters.q || undefined,
        status: filters.status || undefined,
        category: filters.category || undefined,
        sort: filters.sort || undefined
      }

    })

    console.log("API RESPONSE:", res)

    trips.value = res.data || res || []
    pagination.total = res.total || trips.value.length

    calculateStats()

  } catch (err) {

    console.error(err)
    loadError.value = 'โหลดข้อมูลไม่ได้'

  } finally {

    isLoading.value = false

  }
}

function calculateStats() {

  const data = filteredTrips.value

  stats.total = data.reduce(
    (sum, trip) => sum + (trip.reportCount || 0),
    0
  )

  stats.resolvedToday = 0

  stats.byStatus = {
    PENDING: 0,
    UNDER_REVIEW: 0,
    RESOLVED: 0,
    REJECTED: 0
  }

  const today = dayjs().startOf('day')

  data.forEach(trip => {

    if (trip.statusBreakdown) {

      stats.byStatus.PENDING += trip.statusBreakdown.PENDING || 0
      stats.byStatus.UNDER_REVIEW += trip.statusBreakdown.UNDER_REVIEW || 0
      stats.byStatus.RESOLVED += trip.statusBreakdown.RESOLVED || 0
      stats.byStatus.REJECTED += trip.statusBreakdown.REJECTED || 0

    }

    // check resolved today
    if (trip.lastReportAt && trip.statusBreakdown?.RESOLVED > 0) {

      const reportDate = dayjs(trip.lastReportAt)

      if (reportDate.isAfter(today)) {
        stats.resolvedToday += trip.statusBreakdown.RESOLVED
      }

    }

  })

}

function changePage(next) {
    if (next < 1 || next > totalPages.value) return
    fetchTrips(next)
}

function applyFilters() {
    pagination.page = 1
}

function clearFilters() {
    filters.q = ''
    filters.status = ''
    filters.category = ''
    filters.sort = ''
    pagination.page = 1
    fetchTrips(1)
}

function filterByStatus(status) {
    filters.status = status
    applyFilters()
}

function formatDate(date) {

  if (!date) return "-"

  return dayjs(date).format("D MMM YYYY HH:mm")

}

// function onViewReport(report) {
//     // TODO: Navigate to report detail page when it's created
//     navigateTo(`/admin/reports-dashboard/${report.id}`).catch(() => { })
//     console.log('View report:', report.id)
// }

// async function onExportReport(report) {
//     try {
//         // Format report data for export
//         const exportData = {
//             id: report.id,
//             reporter: {
//                 username: report.reporter?.username,
//                 email: report.reporter?.email,
//                 name: `${report.reporter?.firstName || ''} ${report.reporter?.lastName || ''}`.trim()
//             },
//             driver: {
//                 username: report.driver?.username,
//                 email: report.driver?.email,
//                 name: `${report.driver?.firstName || ''} ${report.driver?.lastName || ''}`.trim()
//             },
//             category: formatCategory(report.category),
//             status: formatStatus(report.status),
//             description: report.description,
//             adminNotes: report.adminNotes || '-',
//             createdAt: formatDate(report.createdAt),
//             updatedAt: formatDate(report.updatedAt),
//             resolvedAt: report.resolvedAt ? formatDate(report.resolvedAt) : '-',
//             closedAt: report.closedAt ? formatDate(report.closedAt) : '-'
//         }

//         // Convert to JSON string
//         const jsonStr = JSON.stringify(exportData, null, 2)
        
//         // Create blob and download
//         const blob = new Blob([jsonStr], { type: 'application/json' })
//         const url = URL.createObjectURL(blob)
//         const link = document.createElement('a')
//         link.href = url
//         link.download = `report-${report.id.slice(0, 8)}-${Date.now()}.json`
//         document.body.appendChild(link)
//         link.click()
//         document.body.removeChild(link)
//         URL.revokeObjectURL(url)

//         toast.success('Export สำเร็จ', 'ดาวน์โหลดไฟล์เรียบร้อยแล้ว')
//     } catch (err) {
//         console.error(err)
//         toast.error('Export ไม่สำเร็จ', 'เกิดข้อผิดพลาดในการ export')
//     }
// }

useHead({
    title: 'Report Management - Admin Dashboard',
    link: [{ rel: 'stylesheet', href: 'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css' }]
})

function closeMobileSidebar() {
    const sidebar = document.getElementById('sidebar')
    const overlay = document.getElementById('overlay')
    if (!sidebar || !overlay) return
    sidebar.classList.remove('mobile-open')
    overlay.classList.add('hidden')
}

function defineGlobalScripts() {
    window.toggleSidebar = function () {
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');
        const toggleIcon = document.getElementById('toggle-icon');

        if (!sidebar || !mainContent || !toggleIcon) return;

        sidebar.classList.toggle('collapsed');

        if (sidebar.classList.contains('collapsed')) {
            mainContent.style.marginLeft = '80px';
            toggleIcon.classList.replace('fa-chevron-left', 'fa-chevron-right');
        } else {
            mainContent.style.marginLeft = '280px';
            toggleIcon.classList.replace('fa-chevron-right', 'fa-chevron-left');
        }
    }

    window.toggleMobileSidebar = function () {
        const sidebar = document.getElementById('sidebar');
        const overlay = document.getElementById('overlay');

        if (!sidebar || !overlay) return;

        sidebar.classList.toggle('mobile-open');
        overlay.classList.toggle('hidden');
    }

    window.toggleSubmenu = function (menuId) {
        const menu = document.getElementById(menuId);
        const icon = document.getElementById(menuId + '-icon');

        if (!menu || !icon) return;

        menu.classList.toggle('hidden');

        if (menu.classList.contains('hidden')) {
            icon.classList.replace('fa-chevron-up', 'fa-chevron-down');
        } else {
            icon.classList.replace('fa-chevron-down', 'fa-chevron-up');
        }
    }

    window.__adminResizeHandler__ = function () {
        const sidebar = document.getElementById('sidebar');
        const mainContent = document.getElementById('main-content');
        const overlay = document.getElementById('overlay');

        if (!sidebar || !mainContent || !overlay) return;

        if (window.innerWidth >= 1024) {
            sidebar.classList.remove('mobile-open');
            overlay.classList.add('hidden');

            if (sidebar.classList.contains('collapsed')) {
                mainContent.style.marginLeft = '80px';
            } else {
                mainContent.style.marginLeft = '280px';
            }
        } else {
            mainContent.style.marginLeft = '0';
        }
    }

    window.addEventListener('resize', window.__adminResizeHandler__)
}

function cleanupGlobalScripts() {
    window.removeEventListener('resize', window.__adminResizeHandler__ || (() => { }))
    delete window.toggleSidebar
    delete window.toggleMobileSidebar
    delete window.closeMobileSidebar
    delete window.toggleSubmenu
    delete window.__adminResizeHandler__
}

onMounted(() => {
  defineGlobalScripts()

  if (typeof window.__adminResizeHandler__ === 'function') {
    window.__adminResizeHandler__()
  }

  fetchTrips()
})

onUnmounted(() => {
  cleanupGlobalScripts()
})

</script>

<style scoped>
.sidebar {
    transition: width 0.3s ease;
}

.sidebar.collapsed {
    width: 80px;
}

.sidebar:not(.collapsed) {
    width: 280px;
}

.sidebar-item {
    transition: all 0.3s ease;
}

.sidebar-item:hover {
    background-color: rgba(59, 130, 246, 0.05);
}

.sidebar.collapsed .sidebar-text {
    display: none;
}

.sidebar.collapsed .sidebar-item {
    justify-content: center;
}

.main-content {
    transition: margin-left 0.3s ease;
}

@media (max-width: 768px) {
    .sidebar {
        position: fixed;
        z-index: 1000;
        transform: translateX(-100%);
    }

    .sidebar.mobile-open {
        transform: translateX(0);
    }

    .main-content {
        margin-left: 0 !important;
    }
}
</style>
