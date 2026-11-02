/*
 * (C) Copyright 2019-2021 HP Development Company, L.P.
 * Confidential computer software. Valid license from HP required for possession, use or copying.
 * Consistent with FAR 12.211 and 12.212, Commercial Computer Software,
 * Computer Software Documentation, and Technical Data for Commercial Items are licensed
 * to the U.S. Government under vendor's standard commercial license.
 */

resource "aws_appautoscaling_target" "dynamodb_table_read_target" {
  count = var.auto_scaling_enabled ? 1 : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  service_namespace  = "dynamodb"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  min_capacity       = var.auto_scaling_read_min_capacity
  max_capacity       = var.auto_scaling_read_max_capacity
  resource_id        = format("table/%s", aws_dynamodb_table.table.name)
}

resource "aws_appautoscaling_target" "dynamodb_table_read_target_indexes" {
  count = var.auto_scaling_enabled ? length(var.global_secondary_indexes) : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  service_namespace  = "dynamodb"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  min_capacity       = var.auto_scaling_read_min_capacity
  max_capacity       = var.auto_scaling_read_max_capacity
  resource_id        = format("table/%s/index/%s", aws_dynamodb_table.table.name, var.global_secondary_indexes[count.index].name)
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy" {
  count = var.auto_scaling_enabled ? 1 : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  name               = format("DynamoDBReadCapacityUtilization:%s", aws_appautoscaling_target.dynamodb_table_read_target[0].resource_id)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = var.auto_scaling_read_policy_target
  }
}

resource "aws_appautoscaling_policy" "dynamodb_table_read_policy_indexes" {
  count = var.auto_scaling_enabled ? length(var.global_secondary_indexes) : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  name               = format("DynamoDBReadCapacityUtilization:%s", aws_appautoscaling_target.dynamodb_table_read_target[0].resource_id)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_read_target_indexes[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_read_target_indexes[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_read_target_indexes[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = var.auto_scaling_read_policy_target
  }
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target" {
  count = var.auto_scaling_enabled ? 1 : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  service_namespace  = "dynamodb"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  min_capacity       = var.auto_scaling_write_min_capacity
  max_capacity       = var.auto_scaling_write_max_capacity
  resource_id        = format("table/%s", aws_dynamodb_table.table.name)
}

resource "aws_appautoscaling_target" "dynamodb_table_write_target_indexes" {
  count = var.auto_scaling_enabled ? length(var.global_secondary_indexes) : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  service_namespace  = "dynamodb"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  min_capacity       = var.auto_scaling_write_min_capacity
  max_capacity       = var.auto_scaling_write_max_capacity
  resource_id        = format("table/%s/index/%s", aws_dynamodb_table.table.name, var.global_secondary_indexes[count.index].name)
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy" {
  count = var.auto_scaling_enabled ? 1 : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  name               = format("DynamoDBWriteCapacityUtilization:%s", aws_appautoscaling_target.dynamodb_table_write_target[0].resource_id)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = var.auto_scaling_write_policy_target
  }
}

resource "aws_appautoscaling_policy" "dynamodb_table_write_policy_indexes" {
  count = var.auto_scaling_enabled ? length(var.global_secondary_indexes) : 0
  depends_on = [
    aws_dynamodb_table.table
  ]

  name               = format("DynamoDBWriteCapacityUtilization:%s", aws_appautoscaling_target.dynamodb_table_write_target_indexes[count.index].resource_id)
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.dynamodb_table_write_target_indexes[count.index].resource_id
  scalable_dimension = aws_appautoscaling_target.dynamodb_table_write_target_indexes[count.index].scalable_dimension
  service_namespace  = aws_appautoscaling_target.dynamodb_table_write_target_indexes[count.index].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = var.auto_scaling_write_policy_target
  }
}
