<template>
    <div>
        <AdminHeader />
        <AdminSidebar />

        <main id="main-content" class="main-content mt-16 ml-0 lg:ml-[280px] p-6">

            <!-- Back -->
            <div class="mb-8">
                <NuxtLink
                :to="`/admin/incidents`"
                class="inline-flex items-center gap-2 px-3 py-2 border border-gray-300 rounded-md hover:bg-gray-50"
                >
                <i class="fa-solid fa-arrow-left"></i>
                <span>ย้อนกลับ</span>
                </NuxtLink>
            </div>

            <!-- Title -->
            <div class="flex flex-col gap-3 mb-6 sm:flex-row sm:items-center sm:justify-between">
                <h1 class="text-2xl font-semibold text-gray-800">
                    รายละเอียด Incident
                </h1>
            </div>

            <!-- Loading -->
            <div v-if="isLoading" class="p-8 text-center text-gray-500">
                กำลังโหลดข้อมูล...
            </div>

            <!-- Error -->
            <div v-else-if="loadError" class="p-8 text-center text-red-600">
                {{ loadError }}
            </div>

            <!-- CARD -->
            <div v-else-if="incident" class="bg-white border border-gray-300 rounded-lg shadow-sm overflow-hidden">

                <div class="grid grid-cols-1 lg:grid-cols-4">
                    <!-- LEFT PANEL -->
                    <div class="md:col-span-1 p-4 border-r bg-gray-50">

                        <p>
                            <span class="font-semibold">Incident ID :</span>
                                {{ incident.id }}
                        </p>


                        <p>
                            <span class="font-semibold">Route ID :</span>
                                {{ incident.routeId || '-' }}
                        </p>

                        <p>
                            <span class="font-semibold">สถานะ :</span>
                            <span class="badge">
                                {{ incident.status }}
                            </span>
                        </p>

                        <p>
                            <span class="font-semibold">ผู้แจ้ง :</span>
                                {{ incident.reporter?.firstName }} {{ incident.reporter?.lastName }}
                        </p>

                        <p>
                            <span class="font-semibold">ผู้รับเรื่อง :</span>
                                {{ incident.resolvedBy ? incident.resolvedBy.firstName + ' ' + incident.resolvedBy.lastName : 'ยังไม่มีผู้รับเรื่อง' }}
                        </p>

                        <button
                        v-if="incident.status === 'PENDING'"
                        @click="assignIncident"
                        class="w-full mt-4 bg-green-600 text-white py-2 rounded"
                        >
                            รับเรื่อง
                        </button>

                            <div class="border-t my-6"></div>

                            <p class="font-semibold mb-2">ประวัติสถานะ</p>

                            <!-- created -->
                            <p class="text-sm mb-2">
                            <span class="font-semibold">สร้างเมื่อ :</span>
                            <span class="text-gray-600">
                                {{ formatDate(incident.createdAt) }}
                            </span>
                            </p>

                            <!-- resolved -->
                            <p v-if="incident.resolvedAt" class="text-sm mb-2">
                            <span class="font-semibold">ดำเนินการเมื่อ :</span>
                            <span class="text-gray-600">
                                {{ formatDate(incident.resolvedAt) }}
                            </span>
                            </p>

                            <!-- timeline -->
                            <div v-if="incident?.history?.length">

                            <div
                                v-for="h in incident.history"
                                :key="h.id"
                                class="border-l-2 border-gray-300 pl-3 mb-3"
                            >

                                <p class="text-sm font-medium">
                                {{ h.fromStatus ?? 'เริ่มต้น' }} → {{ h.toStatus }}
                                </p>

                                <p class="text-gray-500 text-sm">
                                {{ h.changedBy?.username }}
                                </p>

                                <p class="text-xs text-gray-400">
                                {{ formatDate(h.createdAt) }}
                                </p>

                            </div>

                            </div>

                            <p v-else class="text-sm text-gray-400">
                            ยังไม่มีประวัติการเปลี่ยนสถานะ
                            </p>

                        </div>

                    <!-- RIGHT PANEL -->
                    <div class="lg:col-span-3 p-6 space-y-6">

                        <div class="grid md:grid-cols-2 gap-4 text-sm">

                            <div>
                                <p class="text-gray-500">หัวข้อ</p>
                                <p class="font-medium">{{ formatCategory(incident.category) }}</p>
                            </div>

                            <div>
                                <p class="text-gray-500">สถานที่เกิดเหตุ</p>

                                <p class="font-medium">
                                    {{ formatLocation(incident.location?.address) }}
                                </p>

                                <div v-if="coordinates" class="mt-4">

                                <iframe
                                :src="`https://www.google.com/maps?q=${coordinates.lat},${coordinates.lng}&z=15&output=embed`"
                                class="w-full h-64 rounded border"
                                loading="lazy"
                                />

                                <a
                                :href="`https://www.google.com/maps?q=${coordinates.lat},${coordinates.lng}`"
                                target="_blank"
                                class="text-blue-600 text-sm hover:underline mt-2 inline-block"
                                >
                                เปิดใน Google Maps
                                </a>

                                </div>

                            </div>

                        </div>

                        <div v-if="incident?.route" class="border-t pt-4">

                        <p class="font-semibold mb-2">รายละเอียดทริป</p>

                            <div class="grid md:grid-cols-2 gap-4 text-sm">

                                <div>
                                <p class="text-gray-500">Trip ID</p>
                                <p class="font-medium">
                                    {{ incident.route.id }}
                                </p>
                                </div>

                                <div v-if="incident.route.driver">
                                <p class="text-gray-500">คนขับ</p>
                                <p class="font-medium">
                                    {{ incident.route.driver.firstName }}
                                    {{ incident.route.driver.lastName }}
                                </p>

                                <!-- Route -->
                                <div v-if="incident.route.origin || incident.route.destination">
                                    <p class="text-gray-500">เส้นทาง</p>
                                    <p class="font-medium">
                                    {{ incident.route.origin }} → {{ incident.route.destination }}
                                    </p>
                                </div>

                                <!-- Passenger count -->
                                <div>
                                    <p class="text-gray-500">จำนวนผู้โดยสาร</p>
                                    <p class="font-medium">
                                    {{ incident.route.bookings?.length || 0 }} คน
                                    </p>
                                </div>

                                </div>

                                

                                <div class="mt-6">

                                    <p class="font-semibold mb-2">
                                    รายชื่อผู้ขับและผู้โดยสารทั้งหมด
                                    </p>

                                    <table class="min-w-full divide-y divide-gray-200 text-sm">

                                    <thead class="bg-gray-50">
                                    <tr>

                                    <th class="px-4 py-3 text-xs text-left text-gray-500 uppercase">
                                    ชื่อ-นามสกุล
                                    </th>

                                    </tr>
                                    </thead>

                                    <tbody class="bg-white divide-y divide-gray-200">

                                    <tr
                                    v-for="u in tripUsers"
                                    :key="u.id"
                                    >

                                    <td class="px-4 py-3">

                                    <span
                                    v-if="u.role === 'driver'"
                                    class="inline-flex items-center px-2 py-1 mr-2 text-xs font-medium text-blue-700 bg-blue-100 rounded-full"
                                    >
                                    คนขับ
                                    </span>

                                    <span
                                    v-else
                                    class="inline-flex items-center px-2 py-1 mr-2 text-xs font-medium text-green-700 bg-green-100 rounded-full"
                                    >
                                    ผู้โดยสาร
                                    </span>

                                    {{ u.firstName }} {{ u.lastName }}

                                    </td>


                                    </tr>

                                    </tbody>
                                    </table>

                                </div>

                            </div>

                        </div>

                        <div class="border-t"></div>

                            <div>
                                <p class="font-semibold">รายละเอียด</p>
                                <p class="text-gray-600">{{ incident.description }}</p>
                            </div>

                        <div class="border-t"></div>

                        <div>

                            <p class="font-semibold">ไฟล์แนบ</p>

                            <div v-if="incident.evidences?.length" class="grid sm:grid-cols-2 gap-6 mt-4">

                                <div
                                v-for="file in incident.evidences"
                                :key="file.id"
                                class="p-4 border-2 border-dashed rounded"
                                >

                                <img
                                v-if="file.type === 'IMAGE'"
                                :src="file.url"
                                class="w-full max-h-96 object-contain"
                                />

                                <video
                                v-else-if="file.type === 'VIDEO'"
                                :src="file.url"
                                controls
                                class="w-full"
                                />

                                <a
                                v-else
                                :href="file.url"
                                target="_blank"
                                class="text-blue-600 underline"
                                >
                                {{ file.fileName }}
                                </a>

                            </div>
                        </div>

                        <p v-else class="text-gray-500 mt-2">
                            ไม่มีไฟล์แนบ
                        </p>

                        </div>

                        <button
                        class="w-full bg-blue-500 hover:bg-blue-600 text-white py-2 rounded"
                        @click="showManageSection = !showManageSection"
                        >
                            {{ showManageSection ? 'ปิดการจัดการ' : 'จัดการเคส' }}
                        </button>

                    </div>
                </div>
            </div>

            <div
            v-if="showManageSection && ['PENDING','UNDER_INVESTIGATION'].includes(incident.status)"
            class="mt-8"
            >

                <div class="bg-white border rounded-lg shadow-sm">

                <div class="px-6 py-4 bg-gray-50">
                <h3 class="text-lg font-semibold">
                จัดการ Incident
                </h3>
                </div>

                <div class="p-6 space-y-6">

                <p v-if="incident.status === 'PENDING'">
                    เคสยังไม่ได้รับการตรวจสอบ
                </p>

                <p v-if="incident.status === 'UNDER_INVESTIGATION'">
                    กำลังตรวจสอบโดยผู้ดูแล
                </p>
                <div v-if="incident.status === 'UNDER_INVESTIGATION'">
                    <label class="block mb-2 text-sm font-medium">
                        หมายเหตุจากผู้ดูแล
                    </label>
                    <textarea
                    v-model="adminNotes"
                    rows="3"
                    class="w-full border rounded px-3 py-2"
                    />
                </div>

                <div
                v-if="incident.status === 'UNDER_INVESTIGATION'"
                class="flex justify-end gap-3"
                >

                <button
                class="px-4 py-2 bg-red-500 text-white rounded disabled:bg-gray-400"
                :disabled="incident.status !== 'UNDER_INVESTIGATION'"
                @click="rejectIncident"
                >
                    ปฏิเสธเคส
                </button>

                <button
                :disabled="incident.status !== 'UNDER_INVESTIGATION' || !adminNotes"
                class="px-4 py-2 bg-green-600 text-white rounded disabled:bg-gray-400"
                @click="resolveIncident"
                >
                    ดำเนินการเคส
                </button>

                </div>

                </div>

                </div>

            </div>

        </main>
    </div> 
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useRoute, useRuntimeConfig, useCookie } from '#app'
import { useToast } from '~/composables/useToast'
import { computed } from 'vue'

const route = useRoute()
const { toast } = useToast()

const incident = ref(null)
const adminNotes = ref('')
const isLoading = ref(true)
const loadError = ref('')
const showManageSection = ref(false)

const tripUsers = computed(() => {
  if (!incident.value?.route) return []

  const users = []

  // driver
  if (incident.value.route.driver) {
    users.push({
      ...incident.value.route.driver,
      role: 'driver'
    })
  }

  // passengers
  const seen = new Set()

  incident.value.route.bookings?.forEach(b => {
    const p = b.passenger

    if (p && !seen.has(p.id)) {
      seen.add(p.id)

      users.push({
        ...p,
        role: 'passenger'
      })
    }
  })

  return users
})

const coordinates = computed(() => {
  const loc = incident.value?.location

  if (!loc) return null

  if (typeof loc === 'object' && loc.lat && loc.lng) {
    return {
      lat: loc.lat,
      lng: loc.lng
    }
  }

  return null
})

async function fetchIncident() {
    const config = useRuntimeConfig()
    const token = useCookie('token').value
    const id = route.params.id

    isLoading.value = true
    loadError.value = ''

    try {
        incident.value = await $fetch(`/incidents/${id}`, {
        baseURL: config.public.apiBase,
        headers: {
            Authorization: `Bearer ${token}`
        }
        })
    } catch (err) {
        console.error(err)
        loadError.value = err?.data?.message || 'โหลดข้อมูลไม่ได้'
    } finally {
        isLoading.value = false
    }

    console.log("INCIDENT:", incident.value)
    console.log("LOCATION:", incident.value?.location)
}

async function assignIncident() {
  const config = useRuntimeConfig()
  const token = useCookie('token').value

  try {
    await $fetch(`/incidents/admin/${incident.value.id}/assign`, {
      method: 'PATCH',
      baseURL: config.public.apiBase,
      headers: {
        Authorization: `Bearer ${token}`
      }
    })

    toast.success('รับเรื่องเรียบร้อย')
    await fetchIncident()

    showManageSection.value = true

  } catch (err) {
    toast.error(err?.data?.message || 'เกิดข้อผิดพลาด')
  }
}

async function resolveIncident() {
  const config = useRuntimeConfig()
  const token = useCookie('token').value
  

  try {
    await $fetch(`/incidents/admin/${incident.value.id}/resolve`, {
      method: 'PATCH',
      baseURL: config.public.apiBase,
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: {
        adminNotes: adminNotes.value
      }
    })

    toast.success('ดำเนินการเคสเรียบร้อย')

    adminNotes.value = ''
    await fetchIncident()

  } catch (err) {
    toast.error(err?.data?.message || 'เกิดข้อผิดพลาด')
  }

  showManageSection.value = false
}

async function rejectIncident() {
  const config = useRuntimeConfig()
  const token = useCookie('token').value

  try {
    await $fetch(`/incidents/admin/${incident.value.id}/reject`, {
      method: 'PATCH',
      baseURL: config.public.apiBase,
      headers: {
        Authorization: `Bearer ${token}`
      },
      body: {
        adminNotes: adminNotes.value
      }
    })

    toast.success('ปฏิเสธเคสเรียบร้อย')

    adminNotes.value = ''
    await fetchIncident()

  } catch (err) {
    toast.error(err?.data?.message || 'เกิดข้อผิดพลาด')
  }

  showManageSection.value = false

}

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

function formatDate(dateStr) {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString('th-TH', {
    dateStyle: 'short',
    timeStyle: 'short'
  })
}

function getUserStatus(u) {

  const now = new Date()

  if (
    (u.driverSuspendedUntil && new Date(u.driverSuspendedUntil) > now) ||
    (u.passengerSuspendedUntil && new Date(u.passengerSuspendedUntil) > now)
  ) {
    return { label: 'แดง (ถูกแบน)', color: 'red' }
  }

  if (u.yellowCardCount > 0) {
    return { label: `ใบเหลือง ${u.yellowCardCount}`, color: 'yellow' }
  }

  return { label: 'ไม่มี', color: 'gray' }

}

function statusClass(u) {
  const s = getUserStatus(u)

  return {
    'text-red-600 font-semibold': s.color === 'red',
    'text-yellow-600 font-semibold': s.color === 'yellow',
    'text-gray-500': s.color === 'gray'
  }
}

function formatLocation(address) {
  if (!address) return '-'

  const parts = address.split(',')

  if (parts.length >= 3) {
    return `${parts[1].trim()}, ${parts[2].trim()}`
  }

  return address
}

onMounted(() => {
  fetchIncident()
})
</script>