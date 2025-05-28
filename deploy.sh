#!/bin/bash

# 早护通后端部署脚本
# 使用方法: ./deploy.sh [环境] [操作]
# 环境: dev|prod
# 操作: build|start|stop|restart|logs|status

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查Docker是否安装
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker未安装，请先安装Docker"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose未安装，请先安装Docker Compose"
        exit 1
    fi
}

# 检查环境文件
check_env_file() {
    local env_file=".env"
    if [ "$1" = "prod" ]; then
        env_file=".env.prod"
    fi
    
    if [ ! -f "$env_file" ]; then
        log_warning "环境文件 $env_file 不存在"
        if [ -f ".env.example" ]; then
            log_info "复制 .env.example 到 $env_file"
            cp .env.example "$env_file"
            log_warning "请编辑 $env_file 文件并填入正确的配置值"
        else
            log_error "请创建 $env_file 文件"
            exit 1
        fi
    fi
}

# 构建镜像
build_image() {
    local env=$1
    log_info "开始构建Docker镜像..."
    
    if [ "$env" = "prod" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml build
    else
        docker-compose build
    fi
    
    log_success "Docker镜像构建完成"
}

# 启动服务
start_service() {
    local env=$1
    log_info "启动服务..."
    
    if [ "$env" = "prod" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
    else
        docker-compose up -d
    fi
    
    log_success "服务启动完成"
    show_status
}

# 停止服务
stop_service() {
    local env=$1
    log_info "停止服务..."
    
    if [ "$env" = "prod" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml down
    else
        docker-compose down
    fi
    
    log_success "服务已停止"
}

# 重启服务
restart_service() {
    local env=$1
    log_info "重启服务..."
    stop_service "$env"
    start_service "$env"
}

# 查看日志
show_logs() {
    local env=$1
    log_info "查看服务日志..."
    
    if [ "$env" = "prod" ]; then
        docker-compose -f docker-compose.yml -f docker-compose.prod.yml logs -f
    else
        docker-compose logs -f
    fi
}

# 查看状态
show_status() {
    log_info "服务状态:"
    docker-compose ps
    
    echo ""
    log_info "健康检查:"
    
    # 等待服务启动
    sleep 5
    
    # 检查健康状态
    if curl -f http://localhost:5000/api/health &> /dev/null; then
        log_success "API服务正常运行"
        echo "访问地址: http://localhost:5000"
        echo "健康检查: http://localhost:5000/api/health"
        echo "API文档: 请查看 API测试指南.md"
    else
        log_error "API服务无法访问"
        log_info "请检查日志: ./deploy.sh $1 logs"
    fi
}

# 清理资源
cleanup() {
    log_info "清理Docker资源..."
    
    # 停止并删除容器
    docker-compose down --remove-orphans
    
    # 删除未使用的镜像
    docker image prune -f
    
    # 删除未使用的卷
    docker volume prune -f
    
    log_success "清理完成"
}

# 备份数据
backup_data() {
    log_info "备份数据库..."
    
    local backup_dir="backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="${backup_dir}/database_${timestamp}.db"
    
    mkdir -p "$backup_dir"
    
    if [ -f "instance/database.db" ]; then
        cp "instance/database.db" "$backup_file"
        log_success "数据库备份完成: $backup_file"
    else
        log_warning "数据库文件不存在"
    fi
}

# 更新部署
update_deployment() {
    local env=$1
    log_info "更新部署..."
    
    # 备份数据
    backup_data
    
    # 拉取最新代码（如果是git仓库）
    if [ -d ".git" ]; then
        log_info "拉取最新代码..."
        git pull
    fi
    
    # 重新构建和启动
    build_image "$env"
    restart_service "$env"
    
    log_success "更新部署完成"
}

# 显示帮助信息
show_help() {
    echo "早护通后端部署脚本"
    echo ""
    echo "使用方法:"
    echo "  $0 [环境] [操作]"
    echo ""
    echo "环境:"
    echo "  dev   - 开发环境（默认）"
    echo "  prod  - 生产环境"
    echo ""
    echo "操作:"
    echo "  build    - 构建Docker镜像"
    echo "  start    - 启动服务"
    echo "  stop     - 停止服务"
    echo "  restart  - 重启服务"
    echo "  logs     - 查看日志"
    echo "  status   - 查看状态"
    echo "  cleanup  - 清理Docker资源"
    echo "  backup   - 备份数据库"
    echo "  update   - 更新部署"
    echo "  help     - 显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 dev start     # 开发环境启动服务"
    echo "  $0 prod restart  # 生产环境重启服务"
    echo "  $0 dev logs      # 查看开发环境日志"
}

# 主函数
main() {
    local env="dev"
    local action="help"
    
    # 解析参数
    if [ $# -ge 1 ]; then
        if [ "$1" = "dev" ] || [ "$1" = "prod" ]; then
            env="$1"
            if [ $# -ge 2 ]; then
                action="$2"
            else
                action="start"
            fi
        else
            action="$1"
        fi
    fi
    
    # 检查Docker
    if [ "$action" != "help" ]; then
        check_docker
    fi
    
    # 检查环境文件
    if [ "$action" != "help" ] && [ "$action" != "cleanup" ]; then
        check_env_file "$env"
    fi
    
    # 执行操作
    case "$action" in
        "build")
            build_image "$env"
            ;;
        "start")
            start_service "$env"
            ;;
        "stop")
            stop_service "$env"
            ;;
        "restart")
            restart_service "$env"
            ;;
        "logs")
            show_logs "$env"
            ;;
        "status")
            show_status
            ;;
        "cleanup")
            cleanup
            ;;
        "backup")
            backup_data
            ;;
        "update")
            update_deployment "$env"
            ;;
        "help")
            show_help
            ;;
        *)
            log_error "未知操作: $action"
            show_help
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"