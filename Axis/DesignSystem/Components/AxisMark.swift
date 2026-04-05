import SwiftUI

struct AxisMark: View {
    var size: CGFloat = 32
    var color: Color = .axisViolet

    var body: some View {
        Canvas { ctx, size in
            // Body — rounded dome shape emerging upward
            var body = Path()
            body.move(to: CGPoint(x: size.width * 0.19, y: size.height))
            body.addLine(to: CGPoint(x: size.width * 0.19, y: size.height * 0.5))
            body.addQuadCurve(
                to: CGPoint(x: size.width * 0.5, y: 0),
                control: CGPoint(x: size.width * 0.19, y: size.height * 0.08)
            )
            body.addQuadCurve(
                to: CGPoint(x: size.width * 0.81, y: size.height * 0.5),
                control: CGPoint(x: size.width * 0.81, y: size.height * 0.08)
            )
            body.addLine(to: CGPoint(x: size.width * 0.81, y: size.height))
            ctx.stroke(body, with: .color(color), lineWidth: size.width * 0.043)

            // Eye — large circle with concentric rings
            let eyeCenter = CGPoint(x: size.width * 0.5, y: size.height * 0.38)
            let eyeR = size.width * 0.17
            ctx.stroke(Circle().path(in: CGRect(
                x: eyeCenter.x - eyeR, y: eyeCenter.y - eyeR,
                width: eyeR * 2, height: eyeR * 2
            )), with: .color(color), lineWidth: size.width * 0.043)

            // Pupil offset to 1 o'clock
            let pupilCenter = CGPoint(x: size.width * 0.528, y: size.height * 0.348)
            ctx.fill(Circle().path(in: CGRect(
                x: pupilCenter.x - size.width * 0.05, y: pupilCenter.y - size.width * 0.05,
                width: size.width * 0.1, height: size.width * 0.1
            )), with: .color(color))

            // Antenna — straight up then kinked right
            var antenna = Path()
            antenna.move(to: CGPoint(x: size.width * 0.5, y: 0))
            antenna.addLine(to: CGPoint(x: size.width * 0.5, y: -size.height * 0.14))
            antenna.addLine(to: CGPoint(x: size.width * 0.563, y: -size.height * 0.3))
            ctx.stroke(antenna, with: .color(color), lineWidth: size.width * 0.043)

            // Ball at antenna tip
            let ballCenter = CGPoint(x: size.width * 0.569, y: -size.height * 0.358)
            ctx.fill(Circle().path(in: CGRect(
                x: ballCenter.x - size.width * 0.094, y: ballCenter.y - size.width * 0.094,
                width: size.width * 0.188, height: size.width * 0.188
            )), with: .color(color))
        }
        .frame(width: size, height: size * 0.7)
        .clipped()
    }
}
