<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">

        <!-- Back -->
        <div class="mb-8">
            <NuxtLink
            to="/admin/reports-dashboard"
            class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
            >
            <i class="fa-solid fa-arrow-left"></i>
            <span>ย้อนกลับ</span>
            </NuxtLink>
        </div>

        <div class="mx-auto max-w-8xl">

            <!-- Title -->
            <div class="flex items-center gap-3 mb-6">
            <h1 class="text-2xl font-semibold text-gray-800">
                รายงานใน Trip นี้
            </h1>
            </div>

            <!-- Trip Summary -->
            <div class="grid grid-cols-1 gap-4 mb-6 sm:grid-cols-2 lg:grid-cols-5">

            <div class="p-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                <p class="text-sm text-gray-600">Total Reports</p>
                <p class="text-2xl font-bold text-gray-900">
                {{ reports.length }}
                </p>
            </div>

            <div class="p-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                <p class="text-sm text-gray-600">Pending</p>
                <p class="text-2xl font-bold text-blue-600">
                    {{ pendingCount }}
                </p>
            </div>

            <div class="p-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                <p class="text-sm text-gray-600">Under Review</p>
                <p class="text-2xl font-bold text-yellow-600">
                {{ reviewCount }}
                </p>
            </div>

            <div class="p-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                <p class="text-sm text-gray-600">Resolved</p>
                <p class="text-2xl font-bold text-green-600">
                {{ resolvedCount }}
                </p>
            </div>

            <div class="p-4 bg-white border border-gray-300 rounded-lg shadow-sm">
                <p class="text-sm text-gray-600">Rejected</p>
                <p class="text-2xl font-bold text-red-600">
                {{ rejectedCount }}
                </p>
            </div>

            </div>

            <!-- Card -->
            <div class="bg-white border border-gray-300 rounded-lg shadow-sm overflow-hidden">


            <div v-if="isLoading" class="py-12 text-center text-gray-500">
                กำลังโหลดข้อมูล...                
            </div>
            <div v-else class="bg-white border border-gray-300 rounded-lg shadow-sm overflow-hidden">
                <!-- Table -->
                 <table class="min-w-full divide-y divide-gray-200">

                <thead class="bg-gray-50">
                <tr>
                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                    Reporter
                    </th>

                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                        Reported User
                    </th>

                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                    Category
                    </th>

                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                    Status
                    </th>

                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                    Created
                    </th>

                    <th class="px-4 py-3 text-xs font-medium text-left text-gray-500 uppercase">
                    Action
                    </th>
                </tr>
                </thead>

                <tbody class="bg-white divide-y divide-gray-200">

                    <tr
                    v-for="report in reports"
                    :key="report.id"
                    class="hover:bg-gray-50"
                    >
                        <td class="px-4 py-3">
                            {{ report.reporter?.firstName }}
                            {{ report.reporter?.lastName }}
                            <!-- <span
                                class="ml-1 px-1.5 py-0.5 text-xs bg-gray-100 text-gray-600 rounded"
                                >
                                {{ report.reportedUser.id === report.route.driverId ? "DRIVER" : "PASSENGER" }}
                            </span> -->
                        </td>

                        <td class="px-4 py-3">

                            <div v-if="report.reportedUser" class="text-sm">
                                {{ report.reportedUser.firstName }}
                                {{ report.reportedUser.lastName }}
                                <!-- <span
                                class="ml-1 px-1.5 py-0.5 text-xs bg-gray-100 text-gray-600 rounded"
                                >
                                    {{ report.reportedUser.id === report.route.driverId ? "DRIVER" : "PASSENGER" }}
                                </span> -->
                            </div>
                        </td>

                        

                        <td class="px-4 py-3">
                            {{ formatCategory(report.category) }}
                        </td>

                        <td class="px-4 py-3">

                        <span
                        class="px-2 py-1 text-xs font-medium rounded-full"
                        :class="statusBadge(report.status)"
                        >
                            {{ report.status }}
                        </span>

                        </td>

                        <td class="px-4 py-3">
                            {{ formatDateTime(report.createdAt) }}
                        </td>

                        <td class="px-4 py-3">

                        <NuxtLink
                        :to="`/admin/reports-dashboard/${report.id}`"
                        class="text-blue-600 hover:text-blue-800"
                        >
                            ดูรายละเอียด
                        </NuxtLink>

                        </td>

                        </tr>

                        <tr v-if="reports.length === 0">
                        <td colspan="6" class="text-center py-8 text-gray-500">
                            ไม่มีรายงานใน Trip นี้
                        </td>
                    </tr>

                </tbody>

            </table>


            </div>
            
            

            </div>

        </div>

        </main>
    </div>
</template>

<script setup>
import { ref, onMounted } from "vue"
import { useRoute, useRuntimeConfig, useCookie } from "#app"

import AdminHeader from '~/components/admin/AdminHeader.vue'
import AdminSidebar from '~/components/admin/AdminSidebar.vue'
import dayjs from "dayjs"

import { computed } from "vue"
const reports = ref([])
const isLoading = ref(true)

const pendingCount = computed(() =>
  reports.value.filter(r => r.status === "PENDING").length
)

const reviewCount = computed(() =>
  reports.value.filter(r => r.status === "UNDER_REVIEW").length
)

const resolvedCount = computed(() =>
  reports.value.filter(r => r.status === "RESOLVED").length
)

const rejectedCount = computed(() =>
  reports.value.filter(r => r.status === "REJECTED").length
)

const route = useRoute()
const config = useRuntimeConfig()



async function fetchReports() {

  const token = useCookie("token").value
  isLoading.value = true

  try {

    const res = await $fetch(`/reports/route/${route.params.routeId}`, {
      baseURL: config.public.apiBase,
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    console.log("API response:", res)

    reports.value = res.data ?? []

    console.log("reports array:", reports.value)

  } catch (err) {

    console.error(err)

  } finally {

    isLoading.value = false

  }

  console.log("routeId:", route.params.routeId)
  console.log("API:", res)

  reports.value = res.data ?? []

  console.log("reports:", reports.value)
  console.log("route params", route.params)
  console.log("routeId:", route.params.routeId)
  console.log("reports array:", reports.value)
}

function formatDateTime(date) {
  if (!date) return "-"
  return dayjs(date).format("D MMM YYYY HH:mm")
}

function formatCategory(category) {
  if (!category) return "-"

  return category
    .toLowerCase()
    .replace(/_/g, " ")
    .replace(/\b\w/g, c => c.toUpperCase())
}

function statusBadge(status) {

  const map = {
    PENDING: "bg-blue-100 text-blue-700",
    UNDER_REVIEW: "bg-yellow-100 text-yellow-700",
    RESOLVED: "bg-green-100 text-green-700",
    REJECTED: "bg-red-100 text-red-700"
  }

  return map[status] || "bg-gray-100 text-gray-700"
}

// function roleBadge(role) {

//   const map = {
//     DRIVER: "bg-blue-100 text-blue-700",
//     PASSENGER: "bg-green-100 text-green-700",
//     ADMIN: "bg-purple-100 text-purple-700"
//   }

//   return map[role] || "bg-gray-100 text-gray-700"

// }

onMounted(fetchReports)
</script>