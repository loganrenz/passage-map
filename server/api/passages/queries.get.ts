import {
  getAllQueries,
  getQueryById,
  getQueriesByPassageId,
  getQueriesByFilename,
} from '~/server/utils/queryRegistry'

export default defineEventHandler(async (event) => {
  const query = getQuery(event)
  const id = query.id as string | undefined
  const passageId = query.passageId as string | undefined
  const filename = query.filename as string | undefined

  try {
    if (id) {
      // Get single query by ID
      const queryData = await getQueryById(id)
      if (!queryData) {
        throw createError({
          statusCode: 404,
          statusMessage: 'Query not found',
        })
      }
      return queryData
    }

    if (passageId) {
      // Get queries by passage ID
      return await getQueriesByPassageId(passageId)
    }

    if (filename) {
      // Get queries by filename
      return await getQueriesByFilename(filename)
    }

    // Get all queries
    return await getAllQueries()
  } catch (error: any) {
    console.error('Error fetching queries:', error)
    throw createError({
      statusCode: error.statusCode || 500,
      statusMessage: error.message || 'Failed to fetch queries',
    })
  }
})

